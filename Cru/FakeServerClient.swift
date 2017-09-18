//
//  FakeServerClient.swift
//  Cru
//
//  Created by Peter Godkin on 4/28/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class FakeServerClient: ServerProtocol {
    var fakeDB: [DBCollection:[[String:AnyObject]]]
    var idCounter: Int
    
    init() {
        fakeDB = [:]
        idCounter = 0
    }
    
    fileprivate func getCollection(_ collection: DBCollection) -> [[String:AnyObject]] {
        if (fakeDB[collection] == nil) {
            fakeDB[collection] = []
        }
        return fakeDB[collection]!
    }
    
    fileprivate func getNewId() -> String {
        idCounter += 1
        return String(idCounter)
    }
    
    func sendHttpGetRequest(_ reqUrl : String, completionHandler : @escaping (AnyObject?) -> Void) {
        let exception = NSException(
            name: NSExceptionName(rawValue: "Not implemented!"),
            reason: "Don't need it yet",
            userInfo: nil
        )
        exception.raise()
    }
    
    func sendHttpPostRequest(_ reqUrl : String, params : [String : AnyObject], completionHandler : @escaping (AnyObject?) -> Void) {
        let exception = NSException(
            name: NSExceptionName(rawValue: "Not implemented!"),
            reason: "Don't need it yet",
            userInfo: nil
        )
        exception.raise()
    }
    
    func joinMinistryTeam(_ ministryTeamId: String, fullName: String, phone: String, callback: @escaping (NSArray?) -> Void) {
        let jimbo = ["name":["first":"Jim", "last":"Bo"], "phone":"1234567890"] as [String : Any]
        let quan = ["name":["first":"Quan", "last":"Tran"], "phone":"0987654321"] as [String : Any]
        
        callback([jimbo, quan])
    }
    
    func joinCommunityGroup(_ groupId: String, fullName: String, phone: String, callback: @escaping (NSArray?) -> Void) {
        let jimbo = ["name":["first":"Jim", "last":"Bo"], "phone":"1234567890"] as [String : Any]
        let quan = ["name":["first":"Quan", "last":"Tran"], "phone":"0987654321"] as [String : Any]
        
        callback([jimbo, quan])
    }
    
    func getById(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void, id: String) {
        
        let dict = getById(collection, id: id)
        
        if (dict != nil) {
            insert(dict! as NSDictionary)
        }
        
        completionHandler(dict != nil)
    }
    
    func deleteById(_ collection: DBCollection, id: String, completionHandler: @escaping (Bool)->Void) {
        completionHandler(deleteById(collection, id: id))
    }
    
    func deleteByIdIn(_ parent: DBCollection, parentId: String, child: DBCollection, childId: String, completionHandler: @escaping (Bool)->Void) {
        if (deleteById(child, id: childId)) {
            completionHandler(false)
        } else {
            var parObj = getById(parent, id: parentId)
            
            //remove the child id from the parent's list of children
            var children = parObj?[child.name()] as! [String]
            children = children.filter() {$0 != childId}
            parObj?[child.name()] = children as AnyObject?
            
            //replace the parent object
             _ = deleteById(parent, id: parentId)
            var parCol = getCollection(parent)
            parCol.append(parObj!)
            fakeDB[parent] = parCol
            
            completionHandler(true)
        }
    }
    
    func postData(_ collection: DBCollection, params: [String:AnyObject], completionHandler: @escaping (NSDictionary?)->Void) {
        completionHandler(postData(collection, params: params) as NSDictionary?)
    }
    
    func postDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, params: [String:Any], completionHandler: @escaping (NSDictionary?)->Void) {
        var parObj = getById(parent, id: parentId)
        if (parObj == nil) {
            completionHandler(nil)
        } else {
            //put the new child object in the child collection
            var childObj = params
            let id = getNewId()
            childObj["_id"] = id as Any?
            var childCol = getCollection(child)
            childCol.append(childObj as [String : AnyObject])
            fakeDB[child] = childCol

            //add new child id to parent's list of children
            var children = parObj?[child.name()] as! [String]
            children.append(id)
            parObj?[child.name()] = children as AnyObject?

            //replace the parent object
            _ = deleteById(parent, id: parentId)
            var parCol = getCollection(parent)
            parCol.append(parObj!)
            fakeDB[parent] = parCol

            completionHandler(childObj as NSDictionary?)
        }
    }
    
    func postDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, params: [String:Any],
        insert: @escaping (NSDictionary)->(), completionHandler: @escaping (Bool)->Void) {
        let exception = NSException(
            name: NSExceptionName(rawValue: "Not implemented!"),
            reason: "Seems complicated",
            userInfo: nil
        )
        exception.raise()
    }

    func getData(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void) {
        let col = getCollection(collection)
        for dict in col {
            insert(dict as NSDictionary)
        }
        completionHandler(true)
    }

    func getData(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void, params: [String:Any]) {
        let exception = NSException(
            name: NSExceptionName(rawValue: "Not implemented!"),
            reason: "Seems complicated",
            userInfo: nil
        )
        exception.raise()
    }
    
    func getDataIn(_ parent: DBCollection, parentId: String, child: DBCollection,
                   insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void) {
        let exception = NSException(
            name: NSExceptionName(rawValue: "Not implemented!"),
            reason: "It's new",
            userInfo: nil
        )
        exception.raise()
    }
    
    func patch(_ collection: DBCollection, params: [String : Any], completionHandler: @escaping (NSDictionary?) -> Void, id: String) {
        var dict = getById(collection, id: id)
        if (dict == nil) {
            completionHandler(nil)
        } else {
            for (k, v) in params {
                dict?[k] = v as AnyObject?
            }

            _ = overrideData(collection, params: dict!)
            completionHandler(dict as NSDictionary?)
        }
    }
    
    func checkConnection(_ handler: @escaping (Bool) -> ()) {
        handler(true)
    }
    
    func checkIfValidNum(_ num: Double, handler: @escaping (Bool)->()){
        
    }
    
    fileprivate func getById(_ collection: DBCollection, id: String) -> [String:AnyObject]! {
        let col = getCollection(collection)
        
        let matches = col.filter() {$0["_id"] as! String == id}
        if (matches.count > 0) {
            // there should only be one element with a matching ID but this is a fake
            return matches[0]
        } else {
            return nil
        }
    }
    
    fileprivate func deleteById(_ collection: DBCollection, id: String) -> Bool {
        var col = getCollection(collection)
        let len = col.count
        col = col.filter() {$0["_id"] as! String != id}
        fakeDB[collection] = col
        
        return len != col.count
    }
    
    fileprivate func postData(_ collection: DBCollection, params: [String: AnyObject]) -> [String:AnyObject] {
        var col = getCollection(collection)
        var dict = params
        
        dict["_id"] = getNewId() as AnyObject?
        col.append(dict)
        fakeDB[collection] = col
        return dict
    }
    
    fileprivate func overrideData(_ collection: DBCollection, params: [String: AnyObject]) -> [String:AnyObject] {
        _ = deleteById(collection, id: params["_id"] as! String)
        
        var col = getCollection(collection)
        let dict = params
        
        col.append(dict)
        fakeDB[collection] = col
        return dict
    }
}
