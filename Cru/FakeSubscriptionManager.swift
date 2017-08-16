//
//  FakeSubscriptionManager.swift
//  Cru
//
//  Created by Peter Godkin on 5/30/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class FakeSubscriptionManager: SubscriptionProtocol {


    fileprivate var fcmToken = "emulator-id-hey-whats-up-hello"
    
    fileprivate let storageManager: LocalStorageManager
    
    init() {
        storageManager = LocalStorageManager()
    }
    
    init(storageManager: LocalStorageManager) {
        self.storageManager = storageManager
    }
    
    func saveFCMToken(_ token: String) {
        fcmToken = token
    }
    
    func loadFCMToken()->String {
        return fcmToken
    }
    
    func loadCampuses() -> [Campus] {
        if let unarchivedObject = storageManager.getObject(Config.campusKey) as? Data {
            if let campuses = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [Campus]{
                return campuses
            }
        }
        return [Campus]()
    }
    
    func saveCampuses(_ campuses:[Campus]) {
        let enabled = campuses.filter{ $0.feedEnabled }
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: enabled as NSArray)
        storageManager.putObject(Config.campusKey, object: archivedObject)
    }
    
    func loadMinistries() -> [Ministry] {
        if let unarchivedObject = storageManager.getObject(Config.ministryKey) as? Data {
            if let ministries = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [Ministry]{
                return ministries
            }
        }
        return [Ministry]()
    }
    
    func saveMinistries(_ ministries:[Ministry], updateGCM: Bool) {
        let enabled = ministries.filter{ $0.feedEnabled }
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: enabled as NSArray)
        storageManager.putObject(Config.ministryKey, object: archivedObject)
    }
    
    func saveMinistries(_ ministries:[Ministry], updateGCM: Bool, handler: @escaping ([String:Bool])->Void) {
        let enabled = ministries.filter{ $0.feedEnabled }
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: enabled as NSArray)
        storageManager.putObject(Config.ministryKey, object: archivedObject)
        var minMap = [String:Bool]()
        enabled.forEach{ minMap[$0.id] = true }
        handler(minMap)
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
        
        return false
    }
    
    func campusContainsMinistry(_ campus: Campus, ministry: Ministry)->Bool {
        return ministry.campusId == campus.id
    }
    
    func subscribeToTopic(_ topic: String) {
        //doesn't need to do anything
    }
    
    func subscribeToTopic(_ topic: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
    
    func unsubscribeToTopic(_ topic: String) {
        //doesn't need to do anything
    }
    
    func unsubscribeToTopic(_ topic: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
}
