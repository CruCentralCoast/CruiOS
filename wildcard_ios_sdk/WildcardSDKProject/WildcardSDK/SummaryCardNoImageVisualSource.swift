//
//  SummaryCardNoImageVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation


open class SummaryCardNoImageVisualSource : BaseVisualSource, CardViewVisualSource{
    
    var header:FullCardHeader!
    var body:SingleParagraphCardBody!
    var footer:ViewOnWebCardFooter!
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.simpleParagraph) as! SingleParagraphCardBody
            body.contentEdgeInset = UIEdgeInsetsMake(0, 15, 5, 15)
        }
        return body;
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
    
    @objc open func viewForCardFooter()->CardViewElement?{
        if(footer == nil){
            footer = CardViewElementFactory.createCardViewElement(WCElementType.viewOnWebFooter) as! ViewOnWebCardFooter
            footer.hairline.isHidden = true
        }
        return footer
    }
}
