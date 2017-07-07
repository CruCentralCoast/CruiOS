//
//  SubscriptionProtocol.swift
//  Cru
//
//  Created by Peter Godkin on 5/30/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

protocol SubscriptionProtocol {
 
    
    func saveFCMToken(_ token: String)
    
    func loadFCMToken()->String
    
    func loadCampuses() -> [Campus]
    
    func saveCampuses(_ campuses:[Campus])
    
    func loadMinistries() -> [Ministry]
    
    func saveMinistries(_ ministrys:[Ministry], updateGCM: Bool)
    
    func saveMinistries(_ ministries:[Ministry], updateGCM: Bool, handler: @escaping ([String:Bool])->Void)
    
    func didMinistriesChange(_ ministries:[Ministry]) -> Bool
    
    func campusContainsMinistry(_ campus: Campus, ministry: Ministry)->Bool
    
    func subscribeToTopic(_ topic: String)
    
    func subscribeToTopic(_ topic: String, handler: @escaping (Bool) -> Void)
    
    func unsubscribeToTopic(_ topic: String)
    
    func unsubscribeToTopic(_ topic: String, handler: @escaping (Bool) -> Void)
}
