//
//  WebLinkCard.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//  Updated by Erica Solum on 9/17/16.
//

/**
Summary Card
*/
@objc
open class SummaryCard : Card {
    
    open let title:String
    open let abstractContent:String
    open let subtitle:String?
    open let media:NSDictionary?
    open let primaryImageURL:URL?
    open let appLinkIos:URL?
    open let tags:[String]?
    
    public init(url:URL, description:String, title:String, media:NSDictionary?, data:NSDictionary?){
        self.title = title
        self.abstractContent = description
        self.media = media
        self.tags = data!["tags"] as? [String]
        
        var cardPrimaryImageURL:URL?
        var cardAppLinkIos:URL?
        var subtitle:String?
        
        if let dataDict = data{
            if let url = dataDict["appLinkIos"] as? String{
                cardAppLinkIos = URL(string: url)
            }
            if let summary = dataDict["summary"] as? NSDictionary{
                subtitle = summary["subtitle"] as? String
            }
        }
        
        if self.media != nil {
            if self.media!["type"] as! String == "image"{
                let imageUrl = self.media!["imageUrl"] as! String
                cardPrimaryImageURL = URL(string:imageUrl)
            }
        }
        
        self.primaryImageURL = cardPrimaryImageURL
        self.appLinkIos = cardAppLinkIos
        self.subtitle = subtitle
        
        super.init(webUrl: url, cardType: "summary")
    }
    
    override class func deserializeFromData(_ data: NSDictionary) -> AnyObject? {
        var summaryCard:SummaryCard?
        var startURL:URL?
        var title:String?
        var description:String?
        
        if let urlString = data["webUrl"] as? String{
            startURL = URL(string:urlString)
        }
        
        if let summary = data["summary"] as? NSDictionary{
            title = summary["title"] as? String
            description = summary["description"] as? String
            if(title != nil && startURL != nil && description != nil){
                let media = summary["media"] as? NSDictionary
                summaryCard = SummaryCard(url: startURL!, description: description!, title: title!, media:media, data:data)
            }
        }
        return summaryCard
    }
    
    open override func supportsLayout(_ layout: WCCardLayout) -> Bool {
        return layout == WCCardLayout.summaryCardTall ||
            layout == WCCardLayout.summaryCardShort ||
            layout == WCCardLayout.summaryCardShortLeft ||
            layout == WCCardLayout.summaryCardNoImage ||
            layout == WCCardLayout.summaryCardImageOnly ||
            layout == WCCardLayout.summaryCardTwitterProfile ||
            layout == WCCardLayout.summaryCardTwitterTweet
    }
}
