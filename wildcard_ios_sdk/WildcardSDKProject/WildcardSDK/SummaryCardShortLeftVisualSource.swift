//
//  SummaryCardShortLeftVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 2/20/15.
//
//

import Foundation



open class SummaryCardShortLeftVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:FullCardHeader!
    var body:ImageFloatLeftBody!
    var footer:ViewOnWebCardFooter!
    
    public override init(card:Card){
        super.init(card: card)
    }
    
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
            body = CardViewElementFactory.createCardViewElement(WCElementType.imageFloatLeft) as! ImageFloatLeftBody
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
