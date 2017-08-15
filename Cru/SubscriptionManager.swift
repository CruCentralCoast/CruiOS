//
//  SubscriptionManager.swift
//  Cru
//
//  Created by Max Crane on 1/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import Firebase

class SubscriptionManager: SubscriptionProtocol {
    
    let fcmKey = "GCM"
    
    fileprivate var unsubList = [String]()
    fileprivate var subList = [String]()
    fileprivate var responses = [String:Bool?]()
    
    fileprivate var successfulMinistries = [Ministry]()
    
    fileprivate static let clientDispatchQueue = DispatchQueue(label: "gcm-subcription-queue", attributes: DispatchQueue.Attributes.concurrent)
    
    fileprivate static func synchronized(_ closure: (Void)->Void) {
        clientDispatchQueue.sync {
            closure()
        }
    }
    
    func saveFCMToken(_ token: String){
        GlobalUtils.saveString(fcmKey, value: token)
    }
    
    func loadFCMToken()->String{
        return GlobalUtils.loadString(fcmKey)
    }
    
    func loadCampuses() -> [Campus] {
        if let unarchivedObject = UserDefaults.standard.object(forKey: Config.campusKey) as? Data {
            if let campuses = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [Campus]{
                return campuses
            }
        }
        return [Campus]()
    }
    
    func saveCampuses(_ campuses:[Campus]) {
        var enabledCampuses = [Campus]()
        
        for camp in campuses{
            if(camp.feedEnabled == true){
                enabledCampuses.append(camp)
            }
        }
        //TODO: Ensure that unsubscribing from a campus will unsubscribe the associate ministries
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: enabledCampuses as NSArray)
        let defaults = UserDefaults.standard
        defaults.set(archivedObject, forKey: Config.campusKey)
        defaults.synchronize()
    }
    
    func loadMinistries() -> [Ministry] {
        if let unarchivedObject = UserDefaults.standard.object(forKey: Config.ministryKey) as? Data {
            if let minisArr = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [Ministry]{
                return minisArr
            }
        }
        return [Ministry]()
    }
    
    func didMinistriesChange(_ ministries:[Ministry]) -> Bool {
        var enabledMinistries = [Ministry]()
        
        for min in ministries {
            if(min.feedEnabled == true){
                enabledMinistries.append(min)
            }
        }

        let oldMinistries = loadMinistries()
        for min in oldMinistries {
            if (!enabledMinistries.contains(min)) {
                return true
            }
        }
        for min in enabledMinistries {
            if (!oldMinistries.contains(min)) {
                return true
            }
        }
        
        return oldMinistries.count != enabledMinistries.count
    }
    
    func saveMinistries(_ ministries:[Ministry], updateGCM: Bool) {
        saveMinistries(ministries, updateGCM: updateGCM, handler: {(map) in })
    }
    
    func saveMinistries(_ ministries:[Ministry], updateGCM: Bool, handler: @escaping ([String:Bool])->Void) {
        
        var enabledMinistries = [Ministry]()
        
        for min in ministries {
            if(min.feedEnabled == true){
                enabledMinistries.append(min)
            }
        }
        print("updating device ministry data")
        
        if(updateGCM){
            print("updating gcm")
            // unsubcribe from ministries you are no longer in
            // and subscribe to ones that you just joined
            let oldMinistries = loadMinistries()
            for min in oldMinistries {
                if (!enabledMinistries.contains(min)) {
                    unsubList.append(min.id)
                    responses[min.id] = nil
                }
            }
            for min in enabledMinistries {
                if (!oldMinistries.contains(min)) {
                    subList.append(min.id)
                    responses[min.id] = nil
                }
            }
            successfulMinistries = enabledMinistries
            sendRequests(handler)
        }
    }
    
    fileprivate func sendRequests(_ handler: @escaping ([String:Bool])->Void) {
        
        subList.forEach {
            let minId = $0
            subscribeToTopic("/topics/" + minId, handler: {(success) in
                SubscriptionManager.synchronized() {
                    self.checkFinished(success, minId: minId, handler: handler)
                }
            })
        }
        
        unsubList.forEach {
            let minId = $0
            unsubscribeToTopic("/topics/" + minId, handler: {(success) in
                SubscriptionManager.synchronized() {
                    self.checkFinished(success, minId: minId, handler: handler)
                }
            })
        }
    }
    
    fileprivate func checkFinished(_ success: Bool, minId: String, handler: ([String:Bool])->Void) {
        self.responses[minId] = success
        if (!success) {
            self.successfulMinistries = self.successfulMinistries.filter { $0.id != minId }
        }
        
        if (responses.reduce(true) {(result, cur) in (cur != nil) && result}) {
            var responseMap = [String:Bool]()
            responses.forEach {(pair) in responseMap[pair.0] = pair.1 }
            handler(responseMap)
            print("Yup")
            print("responses: \(responses)")
            
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: successfulMinistries as NSArray)
            let defaults = UserDefaults.standard
            defaults.set(archivedObject, forKey: Config.ministryKey)
            defaults.synchronize()
        } else {
            print("Nope")
        }
    }
    
    func campusContainsMinistry(_ campus: Campus, ministry: Ministry)->Bool{
        return ministry.campusId == campus.id
    }
    
    func subscribeToTopic(_ topic: String) {
        subscribeToTopic(topic, handler : {(success) in })
    }
    
    func subscribeToTopic(_ topic: String, handler: @escaping (Bool) -> Void) {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        let fcmToken = loadFCMToken()
        Messaging.messaging().subscribe(toTopic: topic)
//        GCMPubSub.sharedInstance().subscribe(withToken: fcmToken, topic: topic,
//            options: nil, handler: {(error) -> Void in
//                let err = error! as NSError
//                var success : Bool = false
//                
//                if (err != nil) {
//                    // Treat the "already subscribed" error more gently
//                    
//                    if err.code == 3001 {
//                        print("Already subscribed to \(topic)")
//                    } else {
//                        print("Subscription failed: \(error?.localizedDescription)");
//                    }
//                } else {
//                    success = true
//                    NSLog("Subscribed to \(topic)");
//                }
//                handler(success)
//        })
    }
    
    func unsubscribeToTopic(_ topic: String) {
        unsubscribeToTopic(topic, handler : {(success) in })
    }

    func unsubscribeToTopic(_ topic: String, handler: @escaping (Bool) -> Void) {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        
        let fcmToken = loadFCMToken()
        Messaging.messaging().unsubscribe(fromTopic: topic)
//        GCMPubSub.sharedInstance().unsubscribe(withToken: fcmToken, topic: topic,
//            options: nil, handler: {(error) -> Void in
//                var success : Bool = false
//                if (error != nil) {
//                    print("Failed to unsubscribe: \(error?.localizedDescription)")
//                } else {
//                    success = true
//                    NSLog("Unsubscribed to \(topic)")
//                }
//                handler(success)
//        })
    }
    
    /* New functions required by the Swift 3 changes to protocols */
    
    
    
    
}
