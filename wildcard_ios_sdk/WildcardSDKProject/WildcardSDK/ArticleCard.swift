//
//  ArticleCard.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/3/14.
//  Updated by Erica Solum on 9/17/16.
//

import Foundation

/**
Article Card
*/
@objc
open class ArticleCard : Card{
    
    open let title:String
    open let creator:Creator
    open let abstractContent:String?
    
    open let keywords:[String]?
    open let tags:[String]?
    open let html:String?
    open let publicationDate:Date?
    open let isBreaking:Bool?
    open let source:String?
    open let author:String?
    open let updatedDate:Date?
    open let media:NSDictionary?
    open let appLinkIos:URL?
    open let primaryImageURL:URL?
    
    public init(title:String, abstractContent:String, url:URL,creator:Creator, data:NSDictionary){
        self.title = title
        self.abstractContent = abstractContent
        self.creator = creator
        self.keywords = data["keywords"] as? [String]
        self.tags = data["tags"] as? [String]
        
        if let url = data["appLinkIos"] as? String{
            self.appLinkIos = URL(string: url)
        }else{
            self.appLinkIos = nil
        }
        
        var cardHtml:String?
        var cardPublicationDate:Date?
        var cardUpdatedDate:Date?
        var cardIsBreaking:Bool?
        var cardAuthor:String?
        var cardSource:String?
        var cardMedia:NSDictionary?
        var cardPrimaryImageURL:URL?
        
        // optional fields from article data
        if let article = data["article"] as? NSDictionary{
            if let epochTime = article["publicationDate"] as? TimeInterval{
                cardPublicationDate = Date(timeIntervalSince1970: epochTime/1000)
            }
            
            if let epochTime = article["updatedDate"] as? TimeInterval{
                cardUpdatedDate = Date(timeIntervalSince1970: epochTime/1000)
            }
            
            cardHtml = article["htmlContent"] as? String
            cardAuthor = article["author"] as? String
            cardSource = article["source"] as? String
            cardIsBreaking = article["isBreaking"] as? Bool
            cardMedia = article["media"] as? NSDictionary
            
            if let media = cardMedia{
                if media["type"] as! String == "image"{
                    let imageUrl = media["imageUrl"] as! String
                    cardPrimaryImageURL = URL(string:imageUrl)
                }
            }
        }
        
        self.html = cardHtml
        self.publicationDate = cardPublicationDate;
        self.updatedDate = cardUpdatedDate
        self.isBreaking = cardIsBreaking;
        self.source = cardSource
        self.author = cardAuthor
        self.media = cardMedia
        self.primaryImageURL = cardPrimaryImageURL
        
        super.init(webUrl: url, cardType: "article")
    }
    
    override class func deserializeFromData(_ data: NSDictionary) -> AnyObject? {
        var articleCard:ArticleCard?
        
        var startURL:URL?
        var title:String?
        var abstractContent:String?
        var creator:Creator?
        if let urlString = data["webUrl"] as? String{
            startURL = URL(string:urlString)
        }
        
        if let creatorData = data["creator"] as? NSDictionary{
            creator = Creator.deserializeFromData(creatorData) as? Creator
        }
        
        if let article = data["article"] as? NSDictionary{
            title = article["title"] as? String
            abstractContent = article["abstractContent"] as? String
            if(title != nil && abstractContent != nil && startURL != nil && creator != nil){
                articleCard = ArticleCard(title: title!, abstractContent: abstractContent!, url: startURL!, creator:creator!, data:data)
            }
        }
        return articleCard
    }
    
    open override func supportsLayout(_ layout: WCCardLayout) -> Bool {
        return layout == WCCardLayout.articleCardTall ||
            layout == WCCardLayout.articleCardShort ||
            layout == WCCardLayout.articleCardNoImage
    }
    
}
