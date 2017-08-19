//
//  ServerClient.swift
//  Cru
//
//  Created by Peter Godkin on 4/24/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

protocol ServerProtocol {

    // gets data from collection, calls insert on each one, then call the completion handler with true
    // if there was no response the completion handler is called with false
    func getData(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void)
    
    //does the same as the function above but only gets data that match the params
    func getData(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void, params: [String:Any])
    
    func getDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, insert: @escaping (NSDictionary) -> (),
        completionHandler: @escaping (Bool)->Void)
    
    func getById(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void, id: String)
    
    func postData(_ collection: DBCollection, params: [String:AnyObject], completionHandler: @escaping (NSDictionary?)->Void)
    
    func postDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, params: [String:Any], completionHandler: @escaping (NSDictionary?)->Void)
    
    func postDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, params: [String:Any],
        insert: @escaping (NSDictionary)->(), completionHandler: @escaping (Bool)->Void)
    
    func deleteById(_ collection: DBCollection, id: String, completionHandler: @escaping (Bool)->Void)
    
    func deleteByIdIn(_ parent: DBCollection, parentId: String, child: DBCollection, childId: String, completionHandler: @escaping (Bool)->Void)
    
    func patch(_ collection: DBCollection, params: [String:Any], completionHandler: @escaping (NSDictionary?)->Void, id: String)
    
    func upload(_ collection: DBCollection, image: Data, completionHandler: @escaping (NSDictionary?)->Void, id: String)
    
    func sendHttpGetRequest(_ reqUrl : String, completionHandler : @escaping (AnyObject?) -> Void)
    
    func sendHttpPostRequest(_ reqUrl : String, params : [String : AnyObject], completionHandler : @escaping (AnyObject?) -> Void)
    
    func checkConnection(_ handler: @escaping (Bool)->())
    
    func checkIfValidNum(_ num: Double, handler: @escaping (Bool)->())
    
    // Send a request to the server with the users name, phonenumber and the id of the team they want to join.
    // The server should return a list containing the contact info for each team leader or nil if there was no
    // response from the server
    func joinMinistryTeam(_ ministryTeamId: String, fullName: String, phone: String, callback: @escaping (NSArray?) -> Void)
    
    func joinCommunityGroup(_ groupId: String, fullName: String, phone: String, callback: @escaping (NSArray?) -> Void)
}
