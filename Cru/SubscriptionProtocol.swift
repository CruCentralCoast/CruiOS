//
//  SubscriptionProtocol.swift
//  Cru
//
//  Created by Peter Godkin on 5/30/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

protocol SubscriptionProtocol {
 
    
    func saveGCMToken(token: String)
    
    func loadGCMToken()->String
    
    func loadCampuses() -> [Campus]
    
    func saveCampuses(campuses:[Campus])
    
    func loadMinistries() -> [Ministry]
    
    func saveMinistries(ministrys:[Ministry], updateGCM: Bool)
    
    func saveMinistries(ministries:[Ministry], updateGCM: Bool, handler: [String:Bool]->Void)
    
    func didMinistriesChange(ministries:[Ministry]) -> Bool
    
    func campusContainsMinistry(campus: Campus, ministry: Ministry)->Bool
    
    func subscribeToTopic(topic: String)
    
    func subscribeToTopic(topic: String, handler: (Bool) -> Void)
    
    func unsubscribeToTopic(topic: String)
    
    func unsubscribeToTopic(topic: String, handler: (Bool) -> Void)
}