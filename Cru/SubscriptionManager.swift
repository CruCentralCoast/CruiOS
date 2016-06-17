//
//  SubscriptionManager.swift
//  Cru
//
//  Created by Max Crane on 1/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import Google

class SubscriptionManager: SubscriptionProtocol {
    
    let gcmKey = "GCM"
    
    private var unsubList = [String]()
    private var subList = [String]()
    private var responses = [String:Bool?]()
    
    private var successfulMinistries = [Ministry]()
    
    private static let clientDispatchQueue = dispatch_queue_create("gcm-subcription-queue", DISPATCH_QUEUE_CONCURRENT)
    
    private static func synchronized(closure: Void->Void) {
        dispatch_sync(clientDispatchQueue) {
            closure()
        }
    }
    
    func saveGCMToken(token: String){
        GlobalUtils.saveString(gcmKey, value: token)
    }
    
    func loadGCMToken()->String{
        return GlobalUtils.loadString(gcmKey)
    }
    
    func loadCampuses() -> [Campus] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(Config.campusKey) as? NSData {
            if let campuses = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [Campus]{
                return campuses
            }
        }
        return [Campus]()
    }
    
    func saveCampuses(campuses:[Campus]) {
        var enabledCampuses = [Campus]()
        
        for camp in campuses{
            if(camp.feedEnabled == true){
                enabledCampuses.append(camp)
            }
        }
        //TODO: Ensure that unsubscribing from a campus will unsubscribe the associate ministries
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(enabledCampuses as NSArray)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: Config.campusKey)
        defaults.synchronize()
    }
    
    func loadMinistries() -> [Ministry] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(Config.ministryKey) as? NSData {
            if let minisArr = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [Ministry]{
                return minisArr
            }
        }
        return [Ministry]()
    }
    
    func didMinistriesChange(ministries:[Ministry]) -> Bool {
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
    
    func saveMinistries(ministries:[Ministry], updateGCM: Bool) {
        saveMinistries(ministries, updateGCM: updateGCM, handler: {(map) in })
    }
    
    func saveMinistries(ministries:[Ministry], updateGCM: Bool, handler: [String:Bool]->Void) {
        
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
    
    private func sendRequests(handler: [String:Bool]->Void) {
        
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
    
    private func checkFinished(success: Bool, minId: String, handler: [String:Bool]->Void) {
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
            
            let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(successfulMinistries as NSArray)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(archivedObject, forKey: Config.ministryKey)
            defaults.synchronize()
        } else {
            print("Nope")
        }
    }
    
    func campusContainsMinistry(campus: Campus, ministry: Ministry)->Bool{
        return ministry.campusId == campus.id
    }
    
    func subscribeToTopic(topic: String) {
        subscribeToTopic(topic, handler : {(success) in })
    }
    
    func subscribeToTopic(topic: String, handler: (Bool) -> Void) {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        let gcmToken = loadGCMToken()
        GCMPubSub.sharedInstance().subscribeWithToken(gcmToken, topic: topic,
            options: nil, handler: {(error) -> Void in
                var success : Bool = false
                if (error != nil) {
                    // Treat the "already subscribed" error more gently
                    if error.code == 3001 {
                        print("Already subscribed to \(topic)")
                    } else {
                        print("Subscription failed: \(error.localizedDescription)");
                    }
                } else {
                    success = true
                    NSLog("Subscribed to \(topic)");
                }
                handler(success)
        })
    }
    
    func unsubscribeToTopic(topic: String) {
        unsubscribeToTopic(topic, handler : {(success) in })
    }

    func unsubscribeToTopic(topic: String, handler: (Bool) -> Void) {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        
        let gcmToken = loadGCMToken()
        
        GCMPubSub.sharedInstance().unsubscribeWithToken(gcmToken, topic: topic,
            options: nil, handler: {(error) -> Void in
                var success : Bool = false
                if (error != nil) {
                    print("Failed to unsubscribe: \(error.localizedDescription)")
                } else {
                    success = true
                    NSLog("Unsubscribed to \(topic)")
                }
                handler(success)
        })
    }
    
    
    
}