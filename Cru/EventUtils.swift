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
    
    func loadEvents(_ inserter: @escaping (NSDictionary)->Void, completionHandler:
        @escaping (Bool)->Void) {
        //Will load all events if user doesn't subscribe to any ministries
        var ministryIds = [String]()
        let ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        //print(ministries)
        ministryIds = ministries.map({min in min.id})
        
        
        let curDate = GlobalUtils.stringFromDate(Date())
        
        let params: [String:Any] = [Event.ministriesField:["$in":ministryIds], Event.endDateField:["$gte": [curDate]]]
        
        
        
        CruClients.getServerClient().getData(.Event, insert: inserter, completionHandler: completionHandler, params: params)
    }
    
    func loadEventsWithoutMinistries(_ inserter: @escaping (NSDictionary)->Void, completionHandler: @escaping (Bool)->Void) {
        let params2: [String: [String: Int] ] = [Event.ministriesField: ["$size": 0]]
        
        CruClients.getServerClient().getData(.Event, insert: inserter, completionHandler: completionHandler, params: params2)
    }
}
