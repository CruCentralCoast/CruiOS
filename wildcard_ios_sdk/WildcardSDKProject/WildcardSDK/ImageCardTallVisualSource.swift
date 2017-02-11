//
//  ImageCardTallVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/31/15.
//
//

import Foundation


open class ImageCardTallVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:ImageOnlyBody!
    var body:FullCardHeader!
    var aspectRatio:CGFloat
    
    public init(card:Card, aspectRatio:CGFloat){
        self.aspectRatio = aspectRatio
        super.init(card:card)
    }
    
    public override init(card:Card){
        // default aspect ratio at 3:4
        aspectRatio = 0.75
        
        // assign aspect ratio if we have it
        if let videoCard = card as? ImageCard{
            if (videoCard.imageSize != CGSize(width: -1, height: -1)){
                aspectRatio = videoCard.imageSize.height / videoCard.imageSize.width
            }
        }
        
        super.init(card: card)
    }
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.imageOnly) as! ImageOnlyBody
            header.contentEdgeInset = UIEdgeInsetsMake(0,0,0,0)
            header.imageAspectRatio = aspectRatio
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            body.contentEdgeInset = UIEdgeInsetsMake(15, 15, 15, 15)
            body.logo.isHidden = true
            body.hairline.isHidden = true
        }
        return body
    }
}
