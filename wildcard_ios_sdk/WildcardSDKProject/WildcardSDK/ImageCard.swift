//
//  ImageCard.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/31/15.
//
//

import Foundation

/**
Image Card
*/
@objc
open class ImageCard : Card{
    
    open let creator:Creator
    open let imageUrl:URL
    
    /// optional size for the image. will be (-1,-1) if size is unavailable
    open let imageSize:CGSize
    
    open let title:String?
    open let imageCaption:String?
    open let keywords:[String]?
    open let appLinkIos:URL?
    
    public init(imageUrl:URL, url:URL,creator:Creator, data:NSDictionary){
        
        self.creator = creator
        self.keywords = data["keywords"] as? [String]
        self.imageUrl = imageUrl
        var imageSize = CGSize(width: -1.0,height: -1.0)
        var cardTitle:String?
        var cardImageCaption:String?
        
        if let url = data["appLinkIos"] as? String{
            self.appLinkIos = URL(string: url)
        }else{
            self.appLinkIos = nil
        }
        
        if let media = data["media"] as? NSDictionary{
            
            cardTitle = media["title"] as? String
            cardImageCaption = media["imageCaption"] as? String
            
            
            if let width = media["width"] as? CGFloat {
                if let height = media["height"] as? CGFloat {
                    imageSize = CGSize(width: width, height: height)
                }
            }
        }
        
        self.imageSize = imageSize
        self.title = cardTitle
        self.imageCaption = cardImageCaption
        
        super.init(webUrl: url, cardType: "image")
    }
    
    override class func deserializeFromData(_ data: NSDictionary) -> AnyObject? {
        
        var imageCard:ImageCard?
        
        var startURL:URL?
        var creator:Creator?
        var imageUrl:URL?
        
        if let urlString = data["webUrl"] as? String{
            startURL = URL(string:urlString)
        }
        
        if let creatorData = data["creator"] as? NSDictionary{
            creator = Creator.deserializeFromData(creatorData) as? Creator
        }
        
        if let media = data["media"] as? NSDictionary{
            
            if let urlString = media["imageUrl"] as? String{
                imageUrl = URL(string:urlString)
            }
            
            if(startURL != nil && creator != nil && imageUrl != nil){
                imageCard = ImageCard(imageUrl:imageUrl!, url: startURL!, creator:creator!, data:data)
            }
        }
        return imageCard
        
    }
    
    open override func supportsLayout(_ layout: WCCardLayout) -> Bool {
        return  layout == .imageCard4x3 ||
                layout == .imageCardAspectFit ||
                layout == .imageCardImageOnly
    }
}
