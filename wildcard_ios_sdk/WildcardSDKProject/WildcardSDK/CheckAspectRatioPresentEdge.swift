//
//  CheckAspectRatioPresentEdge.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/31/15.
//
//

import Foundation

class CheckAspectRatioPresentEdge : LayoutDecisionEdge{
    
    init(){
        super.init(description:"Aspect ratio is available")
    }
    
    override func evaluation(_ input: AnyObject) -> Bool {
        if let card = input as? Card{
            switch card.type{
            case .image:
                let imageCard = card as! ImageCard
                if imageCard.imageSize != CGSize(width: -1, height: -1){
                    // aspect ratio is available for this image card
                    return true
                }else{
                    return false
                }
            default:
                return false
            }
        }
        return false
    }
    
}
