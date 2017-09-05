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
    
    func sendHttpGetRequest(_ reqUrl : String, completionHandler : @escaping (AnyObject?) -> Void) {
        sendHttpRequest(method: .get, reqUrl: reqUrl, params: nil, completionHandler: completionHandler)
    }
    
    func sendHttpPostRequest(_ reqUrl : String, params : [String : AnyObject], completionHandler : @escaping (AnyObject?) -> Void) {
        sendHttpRequest(method: .post, reqUrl: reqUrl, params: params, completionHandler: completionHandler)
    }
    
    fileprivate func sendHttpRequest(method : Alamofire.HTTPMethod, reqUrl : String, params : [String : AnyObject]?, completionHandler : @escaping (AnyObject?) -> Void) {
        // Alamofire 4
        
        Alamofire.request(reqUrl, method: method, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as AnyObject?)
        }
        
        //Alamofire 3 - old request
        /*Alamofire.request(method, reqUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value)
        }*/
    }
    
    // Send a request to the server with the users name, phonenumber and the id of the team they want to join.
    // The server should return a list containing the contact info for each team leader
    func joinMinistryTeam(_ ministryTeamId: String, fullName: String, phone: String, callback: @escaping (NSArray?) -> Void) {
        let url = Config.serverEndpoint + DBCollection.MinistryTeam.name() + "/" + ministryTeamId + "/join"
        let params: [String: AnyObject] = ["name": fullName as AnyObject, "phone": phone as AnyObject]
        
        Alamofire.request(url, method: .post, parameters: params)
            .responseJSON { response in
                callback(response.result.value as? NSArray)
        }
        
        /*Alamofire.request(.POST, url, parameters: params).responseJSON {
            response in
            
            callback(response.result.value as? NSArray)
        }*/
    }
    
    func joinCommunityGroup(_ groupId: String, fullName: String, phone: String, callback: @escaping (NSArray?) -> Void) {
        let url = Config.serverEndpoint + DBCollection.CommunityGroup.name() + "/" + groupId + "/join"
        //let url = Config.serverEndpoint + DBCollection.MinistryTeam.name() + "/" + ministryTeamId + "/join"
        let params: [String: AnyObject] = ["name": fullName as AnyObject, "phone": phone as AnyObject]
        
        Alamofire.request(url, method: .post, parameters: params)
            .responseJSON { response in
                callback(response.result.value as? NSArray)
        }
        
        /*Alamofire.request(.POST, url, parameters: params).responseJSON {
         response in
         
         callback(response.result.value as? NSArray)
         }*/
    }
    
    func getById(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void, id: String) {
        var reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        print ("Get data by id from \(reqUrl)")
        /*if (LoginUtils.isLoggedIn()) { // I think this was for security but the leader api key is no longer returned during login
            reqUrl += "?" + Config.leaderApiKey + "=" + GlobalUtils.loadString(Config.leaderApiKey)
        }*/
        
        Alamofire.request(reqUrl, method: .get)
            .responseJSON { response in
                if let dict = response.result.value as? NSDictionary {
                    insert(dict)
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
        }
        
        /*Alamofire.request(.GET, reqUrl)
            .responseJSON { response in
                if let dict = response.result.value as? NSDictionary {
                    insert(dict)
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
        }*/
    }
    
    func deleteById(_ collection: DBCollection, id: String, completionHandler: @escaping (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        Alamofire.request(reqUrl, method: .delete)
            .responseJSON { response in
                completionHandler(response.result.isSuccess)
        }
        
        //Alamofire 3
        /*
        Alamofire.request(.DELETE, reqUrl)
            .responseJSON { response in
                completionHandler(response.result.isSuccess)
        }*/
    }
    
    func deleteByIdIn(_ parent: DBCollection, parentId: String, child: DBCollection, childId: String, completionHandler: @escaping (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name() + "/" + childId
        Alamofire.request(reqUrl, method: .delete)
            .responseJSON { response in
                completionHandler(response.result.isSuccess)
        }
        
        /*
        Alamofire.request(.DELETE, reqUrl)
            .responseJSON { response in
                completionHandler(response.result.isSuccess)
        }*/
    }
    
    func postData(_ collection: DBCollection, params: [String:AnyObject], completionHandler: @escaping (NSDictionary?)->Void) {
        let requestUrl = Config.serverEndpoint + collection.name()
        
        Alamofire.request(requestUrl, method: .post, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }
        
        /*
        Alamofire.request(.POST, requestUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }*/
    }
    
    func postDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, params: [String:Any], completionHandler: @escaping (NSDictionary?)->Void) {
        
        let requestUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name()
        
        Alamofire.request(requestUrl, method: .post, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }
        /*
        Alamofire.request(.POST, requestUrl, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }*/
    }
    
    func postDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, params: [String:Any],
                    insert: @escaping (NSDictionary)->(), completionHandler: @escaping (Bool)->Void) {
        
        let requestUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name()
        
        requestData(requestUrl, method: .post, params: params, insert: insert, completionHandler: completionHandler)
    }
    
    // gets data from server using get endpoint
    func getData(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + collection.name()
        print ("Get data from \(reqUrl)")
        requestData(reqUrl, method: .get, params: nil, insert: insert, completionHandler: completionHandler)
    }
    
    // gets data from server using find endpoint
    func getData(_ collection: DBCollection, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void, params: [String:Any]) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/find"
        print ("Find data from \(reqUrl)")
        requestData(reqUrl, method: .post, params: params, insert: insert, completionHandler: completionHandler)
    }
    
    func getDataIn(_ parent: DBCollection, parentId: String, child: DBCollection, insert: @escaping (NSDictionary) -> (),
                   completionHandler: @escaping (Bool)->Void) {
        let reqUrl = Config.serverEndpoint + parent.name() + "/" + parentId + "/" + child.name()
        requestData(reqUrl, method: .get, params: nil, insert: insert, completionHandler: completionHandler)
    }
    
    func patch(_ collection: DBCollection, params: [String:Any], completionHandler: @escaping (NSDictionary?)->Void, id: String) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        
        Alamofire.request(reqUrl, method: .patch, parameters: params)
            .responseJSON { response in
                completionHandler(response.result.value as? NSDictionary)
        }
    }
    
    // Specifically used for uploading files/images
    func upload(_ collection: DBCollection, image: Data, completionHandler: @escaping (NSDictionary?)->Void, id: String) {
        let reqUrl = Config.serverEndpoint + collection.name() + "/" + id
        let name = id + "-image"
        let fileName = id + "-image.png"
        
        print("name: " + name)
        print("filename: " + fileName)
        print("request URL: " + reqUrl)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image,
                                         withName: name,
                                         fileName: fileName,
                                         mimeType: "image/png")
            },
            to: reqUrl,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseString { response in
                            debugPrint(response)
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                }
            }
        )
    }
    
    func checkConnection(_ handler: @escaping (Bool)->()){
        Alamofire.request(Config.serverEndpoint + "users/phone/1234567890", method: .get)
            .responseJSON { response in
                handler(response.result.isSuccess)
        }
        
        /*Alamofire.request(.GET, Config.serverEndpoint + "users/phone/1234567890")
            .responseJSON{ response in
                handler(response.result.isSuccess)
        }*/
    }
    
    func checkIfValidNum(_ num: Double, handler: @escaping (Bool)->()){
        Alamofire.request(Config.serverEndpoint + "users/phone/" + num.format(".0:"), method: .get)
            .responseJSON { response in
                handler(!response.description.contains("null"))
        }
        /*
        Alamofire.request(.GET, Config.serverEndpoint + "users/phone/" + num.format(".0:"))
            .responseJSON{ response in
                handler(!response.description.contains("null"))
        }*/
    }
    
    fileprivate func requestData(_ url: String, method: Alamofire.HTTPMethod, params: [String:Any]?, insert: @escaping (NSDictionary) -> (), completionHandler: @escaping (Bool)->Void) {
        let reqUrl = url
        if (LoginUtils.isLoggedIn()) {
            //reqUrl += "?" + Config.leaderApiKey + "=" + GlobalUtils.loadString(Config.leaderApiKey)
        }
        
        Alamofire.request(reqUrl, method: method, parameters: params)
            .responseJSON { response in
                self.insertResources(response.result.value as AnyObject?, insert: insert, completionHandler: completionHandler)
        }
        
        /*Alamofire.request(method, reqUrl, parameters: params)
            .responseJSON { response in
                self.insertResources(response.result.value, insert: insert, completionHandler: completionHandler)
        }*/
    }
    
    fileprivate func insertResources(_ value: AnyObject?, insert : (NSDictionary) -> (), completionHandler : (Bool) -> ()) {
        if let items = value as? NSArray {
            for item in items {
                if let dict = item as? [String: AnyObject]{
                    insert(dict as NSDictionary)
                }
            }
            print("Success!")
            completionHandler(true)
        } else {
            print("Failure!")
            //Print thingy here
            completionHandler(false)
        }
    }
}

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
