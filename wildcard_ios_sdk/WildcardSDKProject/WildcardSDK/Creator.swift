//
//  Publisher.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/17/14.
//
//

import Foundation

/**
Creator of a Card

Any entity that owns Card content. This may be a company, specific website, or individual.
*/

open class Creator : PlatformObject {
    
    open let name:String
    open let url:URL
    open let favicon:URL?
    open let iosAppStoreUrl:URL?
    
    public init(name:String, url:URL, favicon:URL?, iosStore:URL?){
        self.name = name
        self.url = url
        self.favicon = favicon
        self.iosAppStoreUrl = iosStore
    }
    
    class func deserializeFromData(_ data: NSDictionary) -> AnyObject? {
        
        let name = data["name"] as? String
        var creatorUrl:URL?
        if let url = data["url"] as? String{
            creatorUrl = URL(string: url)
        }
        
        if(name != nil && creatorUrl != nil){
            var favicon:URL?
            var iosStoreUrl:URL?
            
            if let fav = data["favicon"] as? String{
                favicon = URL(string: fav)
            }
            
            if let iosStore = data["iosAppStoreUrl"] as? String{
                iosStoreUrl = URL(string:iosStore)
            }
            
            return Creator(name:name!, url:creatorUrl!, favicon:favicon, iosStore:iosStoreUrl)
        }else{
            return nil
        }
    }
}
