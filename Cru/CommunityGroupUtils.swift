//
//  CommunityGroupUtils.swift
//  Cru
//
//  Created by Erica Solum on 7/3/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class CommunityGroupUtils {
    
    var serverClient: ServerProtocol
    
    init() {
        serverClient = CruClients.getServerClient()
    }
    
    init(serverProtocol: ServerProtocol) {
        serverClient = serverProtocol
    }
    
    func loadGroups(_ inserter: @escaping (NSDictionary)->Void, completionHandler:
        @escaping (Bool)->Void) {
        //Will load all community groups if user isn't subscribed to any ministries
        var ministryIds = [String]()
        let ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        //print(ministries)
        ministryIds = ministries.map({min in min.id})
        
        let params: [String:Any] = [CommunityGroupKeys.ministry:["$in":ministryIds]]
        
        
        
        CruClients.getServerClient().getData(.CommunityGroup, insert: inserter, completionHandler: completionHandler, params: params)
        //CruClients.getServerClient().getData(.CommunityGroup, insert: inserter, completionHandler: completionHandler)
    }
    
}
