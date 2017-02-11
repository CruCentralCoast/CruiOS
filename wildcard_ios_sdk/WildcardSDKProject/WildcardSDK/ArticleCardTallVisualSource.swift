//
//  ArticleCardFullImageVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation


open class ArticleCardTallVisualSource : BaseVisualSource, CardViewVisualSource {
    
    var header:FullCardHeader!
    var body:ImageAndCaptionBody!
    var footer:ReadMoreFooter!
    var aspectRatio:CGFloat
    var footerWeb:ViewOnWebCardFooter!
    
    public init(card:Card, aspectRatio:CGFloat){
        self.aspectRatio = aspectRatio
        super.init(card:card)
    }
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            header.hairline.isHidden = true
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            self.body = CardViewElementFactory.createCardViewElement(WCElementType.imageAndCaption) as! ImageAndCaptionBody
            self.body.contentEdgeInset = UIEdgeInsetsMake(0, 15, 0, 15)
            self.body.imageAspectRatio = aspectRatio
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
