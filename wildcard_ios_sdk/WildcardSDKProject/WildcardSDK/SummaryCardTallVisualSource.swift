//
//  SummaryCardFullImageVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation


open class SummaryCardTallVisualSource : BaseVisualSource, CardViewVisualSource {
    
    var header:FullCardHeader!
    var body:ImageAndCaptionBody!
    var footer:ViewOnWebCardFooter!
    var aspectRatio:CGFloat
    
    public init(card:Card, aspectRatio:CGFloat){
        self.aspectRatio = aspectRatio
        super.init(card: card)
    }
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            header.hairline.isHidden = true
            header.logo.isHidden = true
            header.contentEdgeInset = UIEdgeInsetsMake(10, 15, 10, 15)
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.imageAndCaption) as! ImageAndCaptionBody
            body.contentEdgeInset = UIEdgeInsetsMake(0, 15, 5, 15)
            body.imageAspectRatio = aspectRatio
        }
        return body
    }
    
    @objc open func viewForCardFooter() -> CardViewElement? {
        if(footer == nil){
            self.footer = CardViewElementFactory.createCardViewElement(WCElementType.viewOnWebFooter) as! ViewOnWebCardFooter
            self.footer.hairline.isHidden = true
        }
        return footer
    }
}
