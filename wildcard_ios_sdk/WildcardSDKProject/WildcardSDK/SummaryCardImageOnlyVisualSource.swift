//
//  SummaryCardImageOnlyVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 2/6/15.
//
//

import Foundation


open class SummaryCardImageOnlyVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:ImageOnlyBody!
    var body:FullCardHeader!
    var footer:ViewOnWebCardFooter!
    var aspectRatio:CGFloat
    
    public init(card:Card, aspectRatio:CGFloat){
        self.aspectRatio = aspectRatio
        super.init(card: card)
    }
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(.imageOnly) as! ImageOnlyBody
            header.contentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0)
            header.imageAspectRatio = aspectRatio
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(.fullHeader) as! FullCardHeader
            body.contentEdgeInset = UIEdgeInsetsMake(15, 15, 0, 15)
            body.logo.isHidden = true
            body.hairline.isHidden = true
        }
        return body
    }
    
    @objc open func viewForCardFooter() -> CardViewElement? {
        if(footer == nil){
            footer = CardViewElementFactory.createCardViewElement(WCElementType.viewOnWebFooter) as! ViewOnWebCardFooter
            footer.hairline.isHidden = true
            footer.contentEdgeInset = UIEdgeInsetsMake(15, 15, 10, 15)
        }
        return footer
    }
}
