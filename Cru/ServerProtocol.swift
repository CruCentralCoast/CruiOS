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
    func getData(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void)
    
    //does the same as the function above but only gets data that match the params
    func getData(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void, params: [String:AnyObject])
    
    func getDataIn(parent: DBCollection, parentId: String, child: DBCollection, insert: (NSDictionary) -> (),
        completionHandler: (Bool)->Void)
    
    func getById(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void, id: String)
    
    func postData(collection: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void)
    
    func postDataIn(parent: DBCollection, parentId: String, child: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void)
    
    func postDataIn(parent: DBCollection, parentId: String, child: DBCollection, params: [String:AnyObject],
        insert: (NSDictionary)->(), completionHandler: Bool->Void)
    
    func deleteById(collection: DBCollection, id: String, completionHandler: (Bool)->Void)
    
    func deleteByIdIn(parent: DBCollection, parentId: String, child: DBCollection, childId: String, completionHandler: (Bool)->Void)
    
    func patch(collection: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void, id: String)
    
    func sendHttpGetRequest(reqUrl : String, completionHandler : (AnyObject?) -> Void)
    
    func sendHttpPostRequest(reqUrl : String, params : [String : AnyObject], completionHandler : (AnyObject?) -> Void)
    
    func checkConnection(handler: (Bool)->())
    
    func checkIfValidNum(num: Int, handler: (Bool)->())
    
    // Send a request to the server with the users name, phonenumber and the id of the team they want to join.
    // The server should return a list containing the contact info for each team leader or nil if there was no
    // response from the server
    func joinMinistryTeam(ministryTeamId: String, fullName: String, phone: String, callback: (NSArray?) -> Void)
}