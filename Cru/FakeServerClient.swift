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
    
    private func getCollection(collection: DBCollection) -> [[String:AnyObject]] {
        if (fakeDB[collection] == nil) {
            fakeDB[collection] = []
        }
        return fakeDB[collection]!
    }
    
    private func getNewId() -> String {
        idCounter += 1
        return String(idCounter)
    }
    
    func sendHttpGetRequest(reqUrl : String, completionHandler : (AnyObject?) -> Void) {
        let exception = NSException(
            name: "Not implemented!",
            reason: "Don't need it yet",
            userInfo: nil
        )
        exception.raise()
    }
    
    func sendHttpPostRequest(reqUrl : String, params : [String : AnyObject], completionHandler : (AnyObject?) -> Void) {
        let exception = NSException(
            name: "Not implemented!",
            reason: "Don't need it yet",
            userInfo: nil
        )
        exception.raise()
    }
    
    func joinMinistryTeam(ministryTeamId: String, fullName: String, phone: String, callback: (NSArray?) -> Void) {
        let jimbo = ["name":["first":"Jim", "last":"Bo"], "phone":"1234567890"]
        let quan = ["name":["first":"Quan", "last":"Tran"], "phone":"0987654321"]
        
        callback([jimbo, quan])
    }
    
    func getById(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void, id: String) {
        
        let dict = getById(collection, id: id)
        
        if (dict != nil) {
            insert(dict!)
        }
        
        completionHandler(dict != nil)
    }
    
    func deleteById(collection: DBCollection, id: String, completionHandler: (Bool)->Void) {
        completionHandler(deleteById(collection, id: id))
    }
    
    func deleteByIdIn(parent: DBCollection, parentId: String, child: DBCollection, childId: String, completionHandler: (Bool)->Void) {
        if (deleteById(child, id: childId)) {
            completionHandler(false)
        } else {
            var parObj = getById(parent, id: parentId)
            
            //remove the child id from the parent's list of children
            var children = parObj[child.name()] as! [String]
            children = children.filter() {$0 != childId}
            parObj[child.name()] = children
            
            //replace the parent object
            deleteById(parent, id: parentId)
            var parCol = getCollection(parent)
            parCol.append(parObj)
            fakeDB[parent] = parCol
            
            completionHandler(true)
        }
    }
    
    func postData(collection: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void) {
        completionHandler(postData(collection, params: params))
    }
    
    func postDataIn(parent: DBCollection, parentId: String, child: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void) {
        var parObj = getById(parent, id: parentId)
        if (parObj == nil) {
            completionHandler(nil)
        } else {
            //put the new child object in the child collection
            var childObj = params
            let id = getNewId()
            childObj["_id"] = id
            var childCol = getCollection(child)
            childCol.append(childObj)
            fakeDB[child] = childCol

            //add new child id to parent's list of children
            var children = parObj[child.name()] as! [String]
            children.append(id)
            parObj[child.name()] = children

            //replace the parent object
            deleteById(parent, id: parentId)
            var parCol = getCollection(parent)
            parCol.append(parObj)
            fakeDB[parent] = parCol

            completionHandler(childObj)
        }
    }
    
    func postDataIn(parent: DBCollection, parentId: String, child: DBCollection, params: [String:AnyObject],
        insert: (NSDictionary)->(), completionHandler: Bool->Void) {
        let exception = NSException(
            name: "Not implemented!",
            reason: "Seems complicated",
            userInfo: nil
        )
        exception.raise()
    }

    func getData(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void) {
        let col = getCollection(collection)
        for dict in col {
            insert(dict)
        }
        completionHandler(true)
    }

    func getData(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void, params: [String:AnyObject]) {
        let exception = NSException(
            name: "Not implemented!",
            reason: "Seems complicated",
            userInfo: nil
        )
        exception.raise()
    }
    
    func getDataIn(parent: DBCollection, parentId: String, child: DBCollection, insert: (NSDictionary) -> (),
        completionHandler: (Bool)->Void) {
        let exception = NSException(
            name: "Not implemented!",
            reason: "It's new",
            userInfo: nil
        )
        exception.raise()
    }
    
    func patch(collection: DBCollection, params: [String : AnyObject], completionHandler: (NSDictionary?) -> Void, id: String) {
        var dict = getById(collection, id: id)
        if (dict == nil) {
            completionHandler(nil)
        } else {
            for (k, v) in params {
                dict[k] = v
            }

            overrideData(collection, params: dict)
            completionHandler(dict)
        }
    }
    
    func checkConnection(handler: (Bool) -> ()) {
        handler(true)
    }
    
    func checkIfValidNum(num: Double, handler: (Bool)->()){
        
    }
    
    private func getById(collection: DBCollection, id: String) -> [String:AnyObject]! {
        let col = getCollection(collection)
        
        let matches = col.filter() {$0["_id"] as! String == id}
        if (matches.count > 0) {
            // there should only be one element with a matching ID but this is a fake
            return matches[0]
        } else {
            return nil
        }
    }
    
    private func deleteById(collection: DBCollection, id: String) -> Bool {
        var col = getCollection(collection)
        let len = col.count
        col = col.filter() {$0["_id"] as! String != id}
        fakeDB[collection] = col
        
        return len != col.count
    }
    
    private func postData(collection: DBCollection, params: [String: AnyObject]) -> [String:AnyObject] {
        var col = getCollection(collection)
        var dict = params
        
        dict["_id"] = getNewId()
        col.append(dict)
        fakeDB[collection] = col
        return dict
    }
    
    private func overrideData(collection: DBCollection, params: [String: AnyObject]) -> [String:AnyObject] {
        deleteById(collection, id: params["_id"] as! String)
        
        var col = getCollection(collection)
        let dict = params
        
        col.append(dict)
        fakeDB[collection] = col
        return dict
    }
}