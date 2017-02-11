//
//  Platform.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/4/14.
//
//

import Foundation

protocol PlatformObject{
    static func deserializeFromData(_ data:NSDictionary) -> AnyObject?
}

class Platform{
    
    let PLATFORM_BASE_URL = "https://platform-prod.trywildcard.com"
    let API_VERSION = "v1.2"
    
    class var sharedInstance : Platform{
        struct Static{
            static var instance : Platform = Platform()
        }
        return Static.instance
    }
    
    func createWildcardShortLink(_ url:URL, completion:@escaping ((_ url:URL?,_ error:NSError?)->Void)) ->Void
    {
        let targetUrlEncoded = url.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urlString = String(format: "%@/v1.0/shortlink?url=%@", arguments: [Platform.sharedInstance.PLATFORM_BASE_URL, targetUrlEncoded!])
        if let shortLinkPlatformUrl = URL(string:urlString){
            getJsonResponseFromPlatform(shortLinkPlatformUrl) { (json:NSDictionary?, error:NSError?) -> Void in
                if(error == nil){
                    if let shortLink = json!["short_link_result"] as? String{
                        completion(URL(string: shortLink),nil)
                    }else{
                        let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                        completion(nil, error)
                        
                    }
                }else{
                    completion(nil,error)
                }
            }
        }else{
            let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedRequest.rawValue, userInfo: nil)
            completion(nil, error)
        }
    }
    
    func getFromUrl(_ url:URL, completion: ((_ card:Card?, _ error:NSError?)->Void)?) -> Void
    {
        if (WildcardSDK.apiKey != nil){
            
            var params = [AnyHashable: Any]()
            params["url"] = url.absoluteString
            
            WildcardSDK.analytics?.trackEvent("GetCardCalled", withProperties: params, with: nil)
            
            let urlParam = url.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let urlString = String(format: "%@/public/%@/get_card?api_key=%@&web_url=%@", arguments: [Platform.sharedInstance.PLATFORM_BASE_URL, API_VERSION, WildcardSDK.apiKey!, urlParam!])
            
            if let platformUrl = URL(string:urlString){
                getCardJsonResponseFromPlatform(platformUrl) { (json:NSDictionary?, error:NSError?) -> Void in
                    if(error == nil){
                        let returnCard = Card.deserializeFromData(json!) as? Card
                        if (returnCard == nil){
                            let deserializeError = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.cardDeserializationError.rawValue, userInfo: nil)
                            completion?(nil,deserializeError)
                        }else{
                            WildcardSDK.analytics?.trackEvent("GetCardSuccess", withProperties: nil, with: returnCard!)
                            completion?(returnCard,nil)
                        }
                    }else{
                        completion?(nil,error)
                    }
                }
            }else{
                let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedRequest.rawValue, userInfo: nil)
                completion?(nil,error)
            }
            
        }else{
            let notInitializedError = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.uninitializedAPIKey.rawValue, userInfo:nil)
            completion?(nil,notInitializedError)
        }
    }
    
    // MARK: Private
    fileprivate func getCardJsonResponseFromPlatform(_ url:URL, completion:@escaping ((NSDictionary?, NSError?)->Void)) -> Void
    {
        var params = [AnyHashable: Any]()
        params["url"] = url.absoluteString
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue:WildcardSDK.networkDelegateQueue)
        let task:URLSessionTask = session.dataTask(with: url, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
            if(error != nil){
                completion(nil, error)
            }else{
                guard let responseData = data else {
                    let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                    completion(nil,error)
                    return
                }
                
                var json: Dictionary<NSObject, AnyObject>?
                
                do {
                    json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<NSObject,AnyObject>
                } catch {
                    let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                    completion(nil, error)
                    return
                }
                
                let httpResponse = response as! HTTPURLResponse
                if(httpResponse.statusCode == 400){
                    let badRequestError = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.badRequest.rawValue, userInfo: json!)
                    completion(nil,badRequestError)
                }else if(httpResponse.statusCode == 401){
                    let permissionDenied = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.permissionDenied.rawValue, userInfo: json!)
                    completion(nil,permissionDenied)
                }else if(httpResponse.statusCode == 501){
                    WildcardSDK.analytics?.trackEvent("GetCardFailedNotImplemented", withProperties: params, with: nil)
                    let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.notImplemented.rawValue, userInfo: json!)
                    completion(nil,error)
                }else if(httpResponse.statusCode == 500){
                    WildcardSDK.analytics?.trackEvent("GetCardFailedInternalError", withProperties: params, with: nil)
                    let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.internalServerError.rawValue, userInfo: json!)
                    completion(nil,error)
                }else if(httpResponse.statusCode == 200){
                    if let result = json![("result" as AnyObject) as! NSObject] as? NSDictionary{
                        completion(result,nil)
                    }else{
                        let malformedError = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                        completion(nil,malformedError)
                    }
                }else{
                    let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.unknown.rawValue, userInfo: json!)
                    completion(nil,error)
                }
            }
        } as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
    }
    
    fileprivate func getJsonResponseFromPlatform(_ url:URL, completion:@escaping ((NSDictionary?, NSError?)->Void)) -> Void
    {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue:WildcardSDK.networkDelegateQueue)
        let task:URLSessionTask = session.dataTask(with: url, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
            if(error != nil){
                completion(nil, error)
            }else{
                
                guard let responseData = data else {
                    let error = NSError(domain: Bundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.malformedResponse.rawValue, userInfo: nil)
                    completion(nil,error)
                    return
                }
                
                var json:AnyObject?
                
                do {
                    json = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                } catch {
                    let jsonError = NSError(domain: "Error parsing JSON", code: 0, userInfo: nil)
                    completion(nil,jsonError)
                    return
                }

                completion(json! as! NSDictionary, nil)
            }
        } as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
    }
    
}
