//
//  VideoCard.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/9/15.
//  Updated by Erica Solum on 9/17/16.
//

import Foundation

/**
Video Card
*/
@objc
open class VideoCard : Card{
    
    open let title:String
    open let creator:Creator
    open let embedUrl:URL
    
    open let abstractContent:String?
    open let keywords:[String]?
    open let tags:[String]?
    open let appLinkIos:URL?
    open let streamUrl:URL?
    open let streamContentType:String?
    open let posterImageUrl:URL?
    
    public init(title:String, embedUrl:URL, url:URL,creator:Creator, data:NSDictionary){
        
        self.title = title
        self.creator = creator
        self.embedUrl = embedUrl
        self.keywords = data["keywords"] as? [String]
        self.tags = data["tags"] as? [String]
        
        if let url = data["appLinkIos"] as? String{
            self.appLinkIos = URL(string: url)
        }else{
            self.appLinkIos = nil
        }
        
        var cardAbstractContent:String?
        var cardPosterImageUrl:URL?
        var cardStreamContentType:String?
        var cardStreamUrl:URL?
        
        if let media = data["media"] as? NSDictionary{
            
            if let description = media["description"] as? String{
                cardAbstractContent = description
            }
            
            if let imageUrl = media["posterImageUrl"] as? String{
                cardPosterImageUrl = URL(string:imageUrl);
            }
            
            if let contentType = media["streamContentType"] as? String{
                cardStreamContentType = contentType
            }
            
            if let streamUrlString = media["streamUrl"] as? String{
                cardStreamUrl = URL(string: streamUrlString)
            }
        }
        
        self.abstractContent = cardAbstractContent
        self.posterImageUrl = cardPosterImageUrl
        self.streamContentType = cardStreamContentType
        self.streamUrl = cardStreamUrl
        
        super.init(webUrl: url, cardType: "video")
    }
    
    override class func deserializeFromData(_ data: NSDictionary) -> AnyObject? {
        
        var videoCard:VideoCard?
        
        var startURL:URL?
        var title:String?
        var creator:Creator?
        var embeddedURL:URL?
        
        if let urlString = data["webUrl"] as? String{
            startURL = URL(string:urlString)
        }
        
        if let creatorData = data["creator"] as? NSDictionary{
            creator = Creator.deserializeFromData(creatorData) as? Creator
        }
        
        if let media = data["media"] as? NSDictionary{
            title = media["title"] as? String
            
            if let urlString = media["embeddedUrl"] as? String{
                embeddedURL = URL(string:urlString)
            }
            
            if(title != nil && startURL != nil && creator != nil && embeddedURL != nil){
                videoCard = VideoCard(title: title!, embedUrl:embeddedURL!, url: startURL!, creator:creator!, data:data)
            }
        }
        return videoCard
        
    }
    
    open func isYoutube()->Bool{
        return creator.name == "Youtube"
    }
    
    open func isVimeo()->Bool{
        return creator.name == "Vimeo"
    }
    
    open func getYoutubeId()->String?{
        let ytEmbedRegex = "^http(s)://(www.)youtube.com/embed/(.*)$"
        let regex = try? NSRegularExpression(pattern: ytEmbedRegex, options: NSRegularExpression.Options.caseInsensitive)
        
        let length:Int = embedUrl.absoluteString.lengthOfBytes(using: String.Encoding.utf8)
        let ytMatch = regex?.firstMatch(in: embedUrl.absoluteString, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, length))
        if(ytMatch != nil){
            return embedUrl.lastPathComponent
        }else{
            return nil
        }
    }

    open override func supportsLayout(_ layout: WCCardLayout) -> Bool {
        return layout == .videoCardShort ||
               layout == .videoCardThumbnail ||
                layout == .videoCardShortFull
    }

}
