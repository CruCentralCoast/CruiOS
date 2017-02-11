//
//  CardViewVisualSourceFactory.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

class CardViewVisualSourceFactory {
    
    /// Returns a stock visual source from a given card layout.
    class func visualSourceFromLayout(_ layout:WCCardLayout, card:Card)->CardViewVisualSource{
        switch(layout){
        case .summaryCardNoImage:
            let source = SummaryCardNoImageVisualSource(card:card)
            return source
        case .summaryCardShort:
            let source = SummaryCardShortVisualSource(card:card)
            return source
        case .summaryCardShortLeft:
            let source = SummaryCardShortLeftVisualSource(card:card)
            return source
        case .summaryCardTall:
            let source = SummaryCardTallVisualSource(card:card,aspectRatio:0.75)
            return source
        case .summaryCardImageOnly:
            let source = SummaryCardImageOnlyVisualSource(card:card,aspectRatio:0.5625)
            return source
        case .articleCardNoImage:
            let source = ArticleCardNoImageVisualSource(card:card)
            return source
        case .articleCardTall:
            let source = ArticleCardTallVisualSource(card:card, aspectRatio: 0.75)
            return source
        case .articleCardShort:
            let source = ArticleCardShortVisualSource(card:card)
            return source
        case .videoCardShort:
            let source = VideoCardShortImageSource(card:card)
            return source
        case .videoCardThumbnail:
            let source = VideoCardThumbnailImageSource(card:card)
            return source
        case .videoCardShortFull:
            let source = VideoCardShortFullVisualSource(card:card)
            return source
        case .imageCard4x3:
            let source = ImageCardTallVisualSource(card:card, aspectRatio:0.75)
            return source
        case .imageCardAspectFit:
            let source = ImageCardTallVisualSource(card:card)
            return source
        case .imageCardImageOnly:
            let source = ImageCardImageOnlyVisualSource(card:card, aspectRatio:0.75)
            return source
        case .summaryCardTwitterProfile:
            let source = SummaryCardTwitterProfileVisualSource(card:card)
            return source
        case .summaryCardTwitterTweet:
            let source = SummaryCardTwitterTweetVisualSource(card:card)
            return source
        case .unknown:
            // shouldn't happen
            let source = SummaryCardNoImageVisualSource(card:card)
            return source
        }
    }
}
