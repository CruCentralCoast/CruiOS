//
//  CommunityGroupUtils.swift
//  Cru
//
//  Created by Erica Solum on 7/3/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import AmazonS3RequestManager

class CommunityGroupUtils {
    
    var serverClient: ServerProtocol
    var ministries = [Ministry]()
    var ministryTable = [String: String]()
    private var amazonS3Manager: AmazonS3RequestManager
    
    init() {
        serverClient = CruClients.getServerClient()
        amazonS3Manager = AmazonS3RequestManager(bucket: Config.s3BucketName, region: .USWest2, accessKey: Config.awsKey, secret: Config.awsSecret)
    }
    
    init(serverProtocol: ServerProtocol) {
        serverClient = serverProtocol
        amazonS3Manager = AmazonS3RequestManager(bucket: Config.s3BucketName, region: .USWest2, accessKey: Config.awsKey, secret: Config.awsSecret)
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
    
    func getS3Manager() -> AmazonS3RequestManager{
        return amazonS3Manager
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
