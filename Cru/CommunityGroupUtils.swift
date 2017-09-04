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
    var ministries = [Ministry]()
    var ministryTable = [String: String]()
    
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
    
    func getMinistryTable() -> [String: String]{
        if ministries.isEmpty {
            ministries = CruClients.getSubscriptionManager().loadMinistries()
            for ministry in ministries {
                ministryTable[ministry.id] = ministry.name
            }
        }
        return ministryTable
    }
    
    func uploadImage(_ id: String, image: Data, handler: @escaping (CommunityGroup?)->Void){
        serverClient.upload(DBCollection.CommunityGroup, image: image, completionHandler: { dict in
            if dict == nil {
                handler(nil)
            } else {
                handler(CommunityGroup(dict: dict!))
            }
        }, id: id)
    }
    
    func patchGroup(_ id: String, params: [String:Any], handler: @escaping (CommunityGroup?)->Void) {
        serverClient.patch(DBCollection.CommunityGroup, params: params, completionHandler: { dict in
            if dict == nil {
                handler(nil)
            } else {
                handler(CommunityGroup(dict: dict!))
            }
        }, id: id)
    }
    
    func loadLeaders(_ inserter: @escaping (NSDictionary)->Void, parentId: String, completionHandler:
        @escaping (Bool)->Void) {
        serverClient.getDataIn(.CommunityGroup, parentId: parentId, child: .Leader, insert: inserter, completionHandler: completionHandler)
    }
}
