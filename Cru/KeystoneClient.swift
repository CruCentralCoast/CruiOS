//
//  KeystoneClient.swift
//  Cru
//
//  Created by Peter Godkin on 4/24/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import Alamofire

class KeystoneClient: ServerProtocol {
    
    //The following "sendHttp" functions use Alamofire to send http requests to the specified url
    
    func sendHttpGetRequest(reqUrl : String, completionHandler : (AnyObject?) -> Void) {
        sendHttpRequest(.GET, reqUrl: reqUrl, params: nil, completionHandler: completionHandler)
    }
    
    func sendHttpPostRequest(reqUrl : String, params : [String : AnyObject], completionHandler : (AnyObject?) -> Void) {
        sendHttpRequest(.POST, reqUrl: reqUrl, params: params, completionHandler: completionHandler)
    }
    
    private func sendHttpRequest(method : Alamofire.Method, reqUrl : String, params : [String : AnyObject]?, completionHandler : (AnyObject?) -> Void) {
        Alamofire.request(method, reqUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value)
        }
    }
    
    // Send a request to the server with the users name, phonenumber and the id of the team they want to join.
    // The server should return a list containing the contact info for each team leader
    func joinMinistryTeam(ministryTeamId: String, fullName: String, phone: String, callback: (NSArray?) -> Void) {
        let url = Config.serverEndpoint + DBCollection.MinistryTeam.name() + "/" + ministryTeamId + "/join"
        let params: [String: AnyObject] = ["name": fullName, "phone": phone]
        
        Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            
            callback(response.result.value as? NSArray)
        }
    }
    
    func getById(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void, id: String) {
        var reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        print ("Get data by id from \(reqUrl)")
        if (LoginUtils.isLoggedIn()) {
            reqUrl += "?" + Config.leaderApiKey + "=" + GlobalUtils.loadString(Config.leaderApiKey)
        }
        
        Alamofire.request(.GET, reqUrl)
            .responseJSON { response in
                if let dict = response.result.value as? NSDictionary {
                    insert(dict)
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
        }
    }
    
    func deleteById(collection: DBCollection, id: String, completionHandler: (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        
        Alamofire.request(.DELETE, reqUrl)
            .responseJSON { response in
                completionHandler(response.result.isSuccess)
        }
    }
    
    func deleteByIdIn(parent: DBCollection, parentId: String, child: DBCollection, childId: String, completionHandler: (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name() + "/" + childId
        
        Alamofire.request(.DELETE, reqUrl)
            .responseJSON { response in
                completionHandler(response.result.isSuccess)
        }
    }
    
    func postData(collection: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void) {
        let requestUrl = Config.serverEndpoint + collection.name()
        
        Alamofire.request(.POST, requestUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }
    }
    
    func postDataIn(parent: DBCollection, parentId: String, child: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void) {
        
        let requestUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name()
        
        Alamofire.request(.POST, requestUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }
    }
    
    func postDataIn(parent: DBCollection, parentId: String, child: DBCollection, params: [String:AnyObject],
                    insert: (NSDictionary)->(), completionHandler: Bool->Void) {
        
        let requestUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name()
        
        requestData(requestUrl, method: .POST, params: params, insert: insert, completionHandler: completionHandler)
    }
    
    // gets data from server using get endpoint
    func getData(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + collection.name()
        print ("Get data from \(reqUrl)")
        requestData(reqUrl, method: .GET, params: nil, insert: insert, completionHandler: completionHandler)
    }
    
    // gets data from server using find endpoint
    func getData(collection: DBCollection, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void, params: [String:AnyObject]) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/find"
        print ("Find data from \(reqUrl)")
        requestData(reqUrl, method: .POST, params: params, insert: insert, completionHandler: completionHandler)
    }
    
    func getDataIn(parent: DBCollection, parentId: String, child: DBCollection, insert: (NSDictionary) -> (),
                   completionHandler: (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name()
        requestData(reqUrl, method: .GET, params: nil, insert: insert, completionHandler: completionHandler)
    }
    
    func patch(collection: DBCollection, params: [String:AnyObject], completionHandler: (NSDictionary?)->Void, id: String) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        
        Alamofire.request(.PATCH, reqUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }
    }
    
    func checkConnection(handler: (Bool)->()){
        Alamofire.request(.GET, Config.serverEndpoint + "users/phone/1234567890")
            .responseJSON{ response in
                handler(response.result.isSuccess)
        }
    }
    
    func checkIfValidNum(num: Double, handler: (Bool)->()){
        Alamofire.request(.GET, Config.serverEndpoint + "users/phone/" + num.format(".0:"))
            .responseJSON{ response in
                handler(!response.description.containsString("null"))
        }
    }
    
    private func requestData(url: String, method: Alamofire.Method, params: [String:AnyObject]?, insert: (NSDictionary) -> (), completionHandler: (Bool)->Void) {
        var reqUrl = url
        if (LoginUtils.isLoggedIn()) {
            reqUrl += "?" + Config.leaderApiKey + "=" + GlobalUtils.loadString(Config.leaderApiKey)
        }
        
        Alamofire.request(method, reqUrl, parameters: params)
            .responseJSON { response in
                self.insertResources(response.result.value, insert: insert, completionHandler: completionHandler)
        }
    }
    
    private func insertResources(value: AnyObject?, insert : (NSDictionary) -> (), completionHandler : (Bool) -> ()) {
        if let items = value as? NSArray {
            for item in items {
                if let dict = item as? [String: AnyObject]{
                    insert(dict)
                }
            }
            print("Success!")
            completionHandler(true)
        } else {
            print("Failure!")
            completionHandler(false)
        }
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}