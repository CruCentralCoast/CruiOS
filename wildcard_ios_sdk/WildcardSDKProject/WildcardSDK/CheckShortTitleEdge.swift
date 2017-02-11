//
//  CheckShortTitleEdge.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/7/14.
//
//

import Foundation

class CheckShortTitleEdge : LayoutDecisionEdge{
    
    init(){
        super.init(description:"Does this card have a short title?")
    }
    
    let TITLE_THRESHOLD = 40
    
    override func evaluation(_ input: AnyObject) -> Bool {
        if let card = input as? Card{
            switch card.type{
            case .unknown:
                return false
            case .article:
                let articleCard = card as! ArticleCard
                return articleCard.title.characters.count < TITLE_THRESHOLD
            case .summary:
                let summaryCard = card as! SummaryCard
                return summaryCard.title.characters.count < TITLE_THRESHOLD
            case .video:
                let videoCard = card as! VideoCard
                return videoCard.title.characters.count < TITLE_THRESHOLD
            case .image:
                let imageCard = card as! ImageCard
                if imageCard.title != nil {
                    return (imageCard.title!).characters.count < TITLE_THRESHOLD
                }else{
                    return false
                }
            }
        }
        return false
    }
    
    
}
