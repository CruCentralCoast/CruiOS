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
    case success
    case noRides
    case noConnection
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
    func getAvailableEvents(_ fcmid: String, insert: (NSDictionary) -> (), afterFnc : (Bool) -> ()) {
        //Implement in the future?
    }
    
    //Return the list of rides available
    func getRidesNotDriving(_ fcmid: String, insert : @escaping (NSDictionary) -> (),
        afterFunc : @escaping (Bool) -> ()) {

        let fcmArray: [String] = [fcmid]
        let params: [String: Any] =  ["fcm_id": ["$nin" : fcmArray]]
        
        serverClient.getData(DBCollection.Ride, insert: insert, completionHandler: afterFunc, params: params)
    }

    func getPassengerById(_ id: String, insert: @escaping (AnyObject)->(), afterFunc: @escaping (Bool)->Void){
        serverClient.getById(DBCollection.Passenger, insert: insert, completionHandler: afterFunc, id: id)
    }

    func getMyRides(_ insert: @escaping (NSDictionary) -> (), afterFunc: @escaping (ResponseType)->Void) {
        //gets rides you are receiving
        
        
        let rideIds = getMyRideIds()
        
        
        print("There are \(rideIds.count) rides")
        
        if (rideIds.count > 0) {
            let params = ["_id": ["$in": rideIds]]
            
            //GlobalUtils.printRequest(params)
            serverClient.getData(DBCollection.Ride, insert: insert, completionHandler:
                { success in
                    if (success) {
                        afterFunc(.success)
                    } else {
                        afterFunc(.noConnection)
                    }
                }, params: params as [String : AnyObject])
        }
        else{
            //TODO: add something new to serverClient for pinging
            serverClient.getData(DBCollection.Ride, insert: {elem in }, completionHandler:
                {success in
                    if (success) {
                        afterFunc(.noRides)
                    } else {
                        afterFunc(.noConnection)
                    }
            })
        }
    }
    
    fileprivate func getMyRideIds() -> [String] {
        let alsm = ArrayLocalStorageManager(key: Config.ridesOffering)
        var rideIds = alsm.getArray()
        
        let mlsm = MapLocalStorageManager<String>(key: Config.ridesReceiving)
        rideIds += mlsm.keys
        
        return rideIds
    }
    
    static func getMyPassengerMaps() -> LocalStorageManager{
        let mlsm = MapLocalStorageManager<String>(key: Config.ridesReceiving)
        return mlsm
    }

    func postRideOffer(_ eventId : String, name : String , phone : String, seats : Int, time: String,
        location: NSDictionary, radius: Int, direction: String, handler: @escaping (Ride?)->()) {
            let body = ["event":eventId, "driverName":name, "driverNumber":phone, "seats":seats, "time": time,
                "fcm_id": Config.fcmId(), "location":location, "radius":radius, "direction":direction, "gender": 0] as [String : Any]
            
            
            serverClient.postData(DBCollection.Ride, params: body as [String : AnyObject], completionHandler:
                { ride in
                    if let rideDict = ride {
                        
                        if let rideID = rideDict.object(forKey: "_id") {
                            self.saveRideOffering(rideID as! String)
                            handler(Ride(dict: rideDict))
                        }
                        else {
                            handler(nil)
                        }
                    }
                    else {
                        handler(nil)
                    }
                    
                    /*if (ride != nil) {
                        self.saveRideOffering(ride!["_id"] as! String)
                        handler(Ride(dict: ride!))
                    } else {
                        handler(nil)
                    }*/
            })
    }
    
    
    fileprivate func saveRideOffering(_ rideId: String) {
        let alsm = ArrayLocalStorageManager(key: Config.ridesOffering)
        alsm.addElement(rideId)
    }
    
    // adds a passenger to a ride by first adding the passenger to the database, then associating
    // the passenger with the ride
    func joinRide(_ name: String, phone: String, direction: String,  rideId: String, eventId: String, handler: @escaping (Bool)->Void){
        let fcmToken = Config.fcmId()
        let body: [String : AnyObject]
        body = ["name": name as AnyObject, "phone": phone as AnyObject, "direction":direction as AnyObject, "fcm_id":fcmToken as AnyObject, "gender_pref": 0 as AnyObject, "event": eventId as AnyObject, "has_driver": true as AnyObject]
        
        print("New Passenger:")
        print(body)
        
        serverClient.postData(DBCollection.Passenger, params: body, completionHandler:
            { passenger in
                if (passenger != nil) {
                    GlobalUtils.printRequest(passenger!)
                    let passengerId = passenger!["_id"] as! String
                    self.addPassengerToRide(rideId, passengerId: passengerId, eventId: eventId, handler: handler)
                } else {
                    handler(false)
                }
        })
    }
    
    fileprivate func addPassengerToRide(_ rideId: String, passengerId: String, eventId: String, handler : @escaping (Bool)->Void){
        let body = ["_id": passengerId, "event": eventId]
        
        print("Adding Passenger: ")
        print("body: \(body)")
        
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
    
    fileprivate func saveRideReceiving(_ rideId: String, passengerId: String) {
        let mlsm = MapLocalStorageManager<String>(key: Config.ridesReceiving)
        mlsm.save(passengerId, forKey: rideId)
    }
    
    func dropPassenger(_ rideId: String, passengerId: String, handler: @escaping (Bool)->Void){
        serverClient.deleteByIdIn(DBCollection.Ride, parentId: rideId, child: DBCollection.Passenger, childId: passengerId, completionHandler: handler)
    }
    
    
    func leaveRidePassenger(_ ride: Ride, handler: @escaping (Bool)->()){
        let rideId = ride.id
        let mlsm = MapLocalStorageManager<String>(key: Config.ridesReceiving)
        let passId = mlsm.object(forKey: rideId) as! String
        
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
    
    func leaveRideDriver(_ rideid: String, handler: @escaping (Bool)->()){
        
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
    
    func getPassengersByIds(_ ids : [String], inserter : @escaping (NSDictionary) -> (), afterFunc: @escaping (Bool)->Void){
        
        if (ids.count > 0) {
            let params = ["_id":["$in":ids]]
            serverClient.getData(DBCollection.Passenger, insert: inserter, completionHandler: afterFunc, params: params)
        }
    }
    
    func patchRide(_ id: String, params: [String:Any], handler: @escaping (Ride?)->Void) {
        serverClient.patch(DBCollection.Ride, params: params, completionHandler: { dict in
            if dict == nil {
                handler(nil)
            } else {
                handler(Ride(dict: dict!))
            }
            }, id: id)
    }

    func patchPassenger(_ id: String, params: [String:Any], handler: @escaping (Passenger?)->Void) {
        serverClient.patch(DBCollection.Passenger, params: params, completionHandler: { dict in
            if dict == nil {
                handler(nil)
            } else {
                handler(Passenger(dict: dict!))
            }
            }, id: id)
    }
}

// Created for calculating the time in between Dates
extension Date {
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        return ""
    }
}
