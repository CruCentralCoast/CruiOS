//
//  SummaryCardLandscapeImageVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/24/15.
//
//

import Foundation


open class SummaryCardShortVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:FullCardHeader!
    var body:ImageFloatRightBody!
    var footer:ViewOnWebCardFooter!
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            header.logo.isHidden = true
            header.hairline.isHidden = true
            header.contentEdgeInset = UIEdgeInsetsMake(10, 15, 10, 15)
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.imageFloatRight) as! ImageFloatRightBody
            body.contentEdgeInset = UIEdgeInsetsMake(5, 15, 5, 15)
        }
        return body
    }
    
    @objc open func viewForCardFooter() -> CardViewElement? {
        if(footer == nil){
            footer = CardViewElementFactory.createCardViewElement(WCElementType.viewOnWebFooter) as! ViewOnWebCardFooter
            footer.hairline.isHidden = true
        }
        return footer
    }
}
