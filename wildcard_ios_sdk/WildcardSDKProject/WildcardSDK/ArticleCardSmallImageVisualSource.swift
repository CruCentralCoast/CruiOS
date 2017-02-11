//
//  ArticleCard4x3FloatRightImageTextWrapVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation


open class ArticleCardShortVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:FullCardHeader!
    var body:ImageFloatRightBody!
    var footer:ReadMoreFooter!
    var footerWeb:ViewOnWebCardFooter!
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            header.hairline.isHidden = true
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            self.body = CardViewElementFactory.createCardViewElement(WCElementType.imageFloatRight) as! ImageFloatRightBody
            self.body.contentEdgeInset = UIEdgeInsetsMake(5, 15, 0, 15)
        }
        return body
    }
    
    @objc open func viewForCardFooter() -> CardViewElement? {
        if let articleCard = card as? ArticleCard{
            if(articleCard.html == nil){
                if(footerWeb == nil){
                    self.footerWeb = CardViewElementFactory.createCardViewElement(WCElementType.viewOnWebFooter) as! ViewOnWebCardFooter
                    self.footerWeb.hairline.isHidden = true
                }
                return footerWeb
            }else{
                if(footer == nil){
                    self.footer = CardViewElementFactory.createCardViewElement(WCElementType.readMoreFooter) as! ReadMoreFooter
                    self.footer.contentEdgeInset = UIEdgeInsetsMake(15, 15, 15, 15)
                }
                return footer
            }
        }else{
            return nil
        }
    }
}
