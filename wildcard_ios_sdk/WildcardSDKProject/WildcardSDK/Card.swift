//
//  Card.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/3/14.
//
//

import Foundation

/// Card base class
@objc
open class Card : NSObject, PlatformObject {
    
    /// Associated web url for this card
    open let webUrl:URL
    
    open let cardType:String
    open let type:WCCardType
    
    init(webUrl:URL, cardType:String){
        self.webUrl = webUrl
        self.cardType = cardType
        self.type = Card.cardTypeFromString(cardType)
    }
    
    open class func cardTypeFromString(_ name:String!) -> WCCardType{
        if let name = name{
            if(name == "article"){
                return .article
            }else if(name == "summary"){
                return .summary
            }else if(name == "video"){
                return .video
            }else if(name == "image"){
                return .image
            }else{
                return .unknown
            }
        }else{
            return .unknown
        }
    }
    
    open class func stringFromCardType(_ type:WCCardType)->String{
        switch(type){
        case .article:
            return "article"
        case .summary:
            return "summary"
        case .video:
            return "video"
        case .image:
            return "image"
        case .unknown:
            return "unknown"
        }
    }

    /// Gets a card from the specified URL
    open class func getFromUrl(_ url:URL!, completion: ((_ card:Card?, _ error:NSError?)->Void)?) -> Void{
        if let url = url{
            Platform.sharedInstance.getFromUrl(url, completion:completion)
        }else{
            print("getFromUrl() failed, url is nil.")
        }
    }
    
    class func deserializeFromData(_ data: NSDictionary) -> AnyObject? {
        if let cardType = data["cardType"] as? String{
            switch(cardType){
            case "article":
                return ArticleCard.deserializeFromData(data) as? ArticleCard
            case "summary":
                return SummaryCard.deserializeFromData(data) as? SummaryCard
            case "video":
                return VideoCard.deserializeFromData(data) as? VideoCard
            case "image":
                return ImageCard.deserializeFromData(data) as? ImageCard
            default:
                return nil
            }
        }
        return nil
    }
    
    open func supportsLayout(_ layout:WCCardLayout)->Bool{
        return false;
    }
    
    
}
