//
//  RideUtils.swift
//  Cru
//
//  Created by Peter Godkin on 2/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import Alamofire

enum ResponseType{
    case Success
    case NoRides
    case NoConnection
}

class RideUtils {

    var serverClient: ServerProtocol!

    convenience init() {
        self.init(serverProtocol: CruClients.getServerClient())
    }

    init(serverProtocol: ServerProtocol) {
        serverClient = serverProtocol
    }
    
    //Return the list of events excluding those user is giving/getting a ride to
    func getAvailableEvents(gcmid: String, insert: (NSDictionary) -> (), afterFnc : (Bool) -> ()) {
        //Implement in the future?
    }
    
    //Return the list of rides available
    func getRidesNotDriving(gcmid: String, insert : (NSDictionary) -> (),
        afterFunc : (Bool) -> ()) {

        let gcmArray: [String] = [gcmid]
        let params: [String: AnyObject] =  ["gcm_id": ["$nin" : gcmArray]]
        
        serverClient.getData(DBCollection.Ride, insert: insert, completionHandler: afterFunc, params: params)
    }

    func getPassengerById(id: String, insert: (AnyObject)->(), afterFunc: (Bool)->Void){
        serverClient.getById(DBCollection.Passenger, insert: insert, completionHandler: afterFunc, id: id)
    }

    func getMyRides(insert: (NSDictionary) -> (), afterFunc: (ResponseType)->Void) {
        //gets rides you are receiving
        
        
        let rideIds = getMyRideIds()
        
        
        print("There are \(rideIds.count) rides")
        
        if (rideIds.count > 0) {
            let params = ["_id": ["$in": rideIds]]
            
            //GlobalUtils.printRequest(params)
            serverClient.getData(DBCollection.Ride, insert: insert, completionHandler:
                { success in
                    if (success) {
                        afterFunc(.Success)
                    } else {
                        afterFunc(.NoConnection)
                    }
                }, params: params)
        }
        else{
            //TODO: add something new to serverClient for pinging
            serverClient.getData(DBCollection.Ride, insert: {elem in }, completionHandler:
                {success in
                    if (success) {
                        afterFunc(.NoRides)
                    } else {
                        afterFunc(.NoConnection)
                    }
            })
        }
    }
    
    private func getMyRideIds() -> [String] {
        let alsm = ArrayLocalStorageManager(key: Config.ridesOffering)
        var rideIds = alsm.getArray()
        
        let mlsm = MapLocalStorageManager(key: Config.ridesReceiving)
        rideIds += mlsm.getKeys()
        
        return rideIds
    }
    
    static func getMyPassengerMaps() -> LocalStorageManager{
        let mlsm = MapLocalStorageManager(key: Config.ridesReceiving)
        return mlsm
    }

    func postRideOffer(eventId : String, name : String , phone : String, seats : Int, time: String,
        location: NSDictionary, radius: Int, direction: String, handler: (Ride?)->()) {
            let body = ["event":eventId, "driverName":name, "driverNumber":phone, "seats":seats, "time": time,
                "gcm_id": Config.gcmId(), "location":location, "radius":radius, "direction":direction, "gender": 0]
            
            
            serverClient.postData(DBCollection.Ride, params: body, completionHandler:
                { ride in
                    if (ride != nil) {
                        self.saveRideOffering(ride!["_id"] as! String)
                        handler(Ride(dict: ride!))
                    } else {
                        handler(nil)
                    }
            })
    }
    
    
    private func saveRideOffering(rideId: String) {
        let alsm = ArrayLocalStorageManager(key: Config.ridesOffering)
        alsm.addElement(rideId)
    }
    
    // adds a passenger to a ride by first adding the passenger to the database, then associating
    // the passenger with the ride
    func joinRide(name: String, phone: String, direction: String,  rideId: String, handler: (Bool)->Void){
        let gcmToken = Config.gcmId()
        let body: [String : AnyObject]
        body = ["name": name, "phone": phone, "direction":direction, "gcm_id":gcmToken, "gender": 0]
        
        serverClient.postData(DBCollection.Passenger, params: body, completionHandler:
            { passenger in
                if (passenger != nil) {
                    GlobalUtils.printRequest(passenger!)
                    let passengerId = passenger!["_id"] as! String
                    self.addPassengerToRide(rideId, passengerId: passengerId, handler: handler)
                } else {
                    handler(false)
                }
        })
    }
    
    private func addPassengerToRide(rideId: String, passengerId: String, handler : (Bool)->Void){
        let body = ["passenger_id": passengerId]
        
        serverClient.postDataIn(DBCollection.Ride, parentId: rideId, child: DBCollection.Passenger, params: body, completionHandler:
            { response in
                if (response != nil) {
                    self.saveRideReceiving(rideId, passengerId: passengerId)
                    handler(true)
                } else {
                    handler(false)
                }
        })
    }
    
    private func saveRideReceiving(rideId: String, passengerId: String) {
        let mlsm = MapLocalStorageManager(key: Config.ridesReceiving)
        mlsm.addElement(rideId, elem: passengerId)
    }
    
    func dropPassenger(rideId: String, passengerId: String, handler: (Bool)->Void){
        serverClient.deleteByIdIn(DBCollection.Ride, parentId: rideId, child: DBCollection.Passenger, childId: passengerId, completionHandler: handler)
    }
    
    
    func leaveRidePassenger(ride: Ride, handler: (Bool)->()){
        let rideId = ride.id
        let mlsm = MapLocalStorageManager(key: Config.ridesReceiving)
        let passId = mlsm.getElement(rideId) as! String
        
        serverClient.deleteByIdIn(DBCollection.Ride, parentId: rideId, child: DBCollection.Passenger, childId: passId, completionHandler:
            { success in
                if (success) {
                    mlsm.removeElement(rideId)
                    handler(true)
                } else {
                    handler(false)
                }
        })
    }
    
    func leaveRideDriver(rideid: String, handler: (Bool)->()){
        
        serverClient.deleteById(DBCollection.Ride, id: rideid, completionHandler: { success in
            if (success) {
                let alsm = ArrayLocalStorageManager(key: Config.ridesOffering)
                alsm.removeElement(rideid)
                handler(true)
            } else {
                handler(false)
            }
        })
    }
    
    func getPassengersByIds(ids : [String], inserter : (NSDictionary) -> (), afterFunc: (Bool)->Void){
        
        if (ids.count > 0) {
            let params = ["_id":["$in":ids]]
            serverClient.getData(DBCollection.Passenger, insert: inserter, completionHandler: afterFunc, params: params)
        }
    }
    
    func patchRide(id: String, params: [String:AnyObject], handler: (Ride?)->Void) {
        serverClient.patch(DBCollection.Ride, params: params, completionHandler: { dict in
            if dict == nil {
                handler(nil)
            } else {
                handler(Ride(dict: dict!))
            }
            }, id: id)
    }

    func patchPassenger(id: String, params: [String:AnyObject], handler: (Passenger?)->Void) {
        serverClient.patch(DBCollection.Passenger, params: params, completionHandler: { dict in
            if dict == nil {
                handler(nil)
            } else {
                handler(Passenger(dict: dict!))
            }
            }, id: id)
    }
}