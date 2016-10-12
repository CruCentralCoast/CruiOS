//
//  EventUtils.swift
//  Cru
//
//  Created by Peter Godkin on 5/16/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class EventUtils {

    var serverClient: ServerProtocol
    
    init() {
        serverClient = CruClients.getServerClient()
    }
    
    init(serverProtocol: ServerProtocol) {
        serverClient = serverProtocol
    }
    
    func loadEvents(inserter: (NSDictionary)->Void, completionHandler: (Bool)->Void) {
        //Will load all events if you belong to no ministries
        var ministryIds = []
        let ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        print(ministries)
        ministryIds = ministries.map({min in min.id})
        
        
        let curDate = GlobalUtils.stringFromDate(NSDate())
        
        let params: [String:AnyObject] = [Event.ministriesField:["$in":ministryIds], Event.endDateField:["$gte": curDate]]
        
        
        
        CruClients.getServerClient().getData(.Event, insert: inserter, completionHandler: completionHandler, params: params)
    }
    
    func loadEventsWithoutMinistries(inserter: (NSDictionary)->Void, completionHandler: (Bool)->Void) {
        let params2: [String: AnyObject] = [Event.ministriesField: NSNull()]
        CruClients.getServerClient().getData(.Event, insert: inserter, completionHandler: completionHandler, params: params2)
    }
}