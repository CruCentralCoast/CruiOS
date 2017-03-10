//
//  ImageCache.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/10/14.
//
//  Edited by Erica Solum on 2/8/17 for Swift 3
//

import Foundation
import NotificationCenter

class ImageCache: NSCache<AnyObject, AnyObject> {
    // swift doesn't support class constant variables yet, but you can do it in a struct
    static let sharedInstance = ImageCache()
    static var onceToken = 0
    
    public static var StaticInstance : ImageCache {
        get { return sharedInstance }
    }
    
    /*class var sharedInstance : ImageCache{
        struct Static{
            static var onceToken : Int = 0
            static var instance : ImageCache? = nil
        }
        
        _ = ImageCache.__once
        return Static.instance!
    }
     
    
    
    private static var __once: () = { () -> Void in
            Static.instance = ImageCache()
            NotificationCenter.default.addObserver(
                Static.instance!,
                selector: "memoryWarningReceived",
                name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
                object: nil)
        }()*/
    
    
    private override init() {
        NotificationCenter.default.addObserver(
            ImageCache.sharedInstance,
            selector: #selector(ImageCache.memoryWarningReceived),
            name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
            object: nil)
    }
    
    
    
    func memoryWarningReceived(){
        ImageCache.sharedInstance.removeAllObjects()
    }
    
    class func cacheKeyFromRequest(_ request:URLRequest)->String{
        return request.url!.absoluteString
    }
    
    func cachedImageForRequest(_ request:URLRequest)->UIImage?{
        switch request.cachePolicy{
        case NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
        NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData:
            return nil
        default:
            break
        }
        return object(forKey: ImageCache.cacheKeyFromRequest(request) as AnyObject) as? UIImage
    }
    
    func cacheImageForRequest(_ image:UIImage,request:URLRequest){
        setObject(image, forKey: ImageCache.cacheKeyFromRequest(request) as AnyObject)
    }
}
