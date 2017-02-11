//
//  CheckImageEdge.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/7/14.
//
//

import Foundation

class CheckImageEdge : LayoutDecisionEdge
{
    init(){
        super.init(description:"Is image available?")
    }
    
    override func evaluation(_ input: AnyObject) -> Bool {
        if let card = input as? Card{
            switch card.type{
            case .unknown:
                return false
            case .article:
                let articleCard = card as! ArticleCard
                return articleCard.primaryImageURL != nil
            case .summary:
                let summaryCard = card as! SummaryCard
                return summaryCard.primaryImageURL != nil
            case .video:
                let videoCard = card as! VideoCard
                return videoCard.posterImageUrl != nil
            case .image:
                return true
            }
        }
        return false
    }
}
