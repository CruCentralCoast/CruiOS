//
//  CardViewElementFactory.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 2/13/15.
//
//

import Foundation


open class CardViewElementFactory{
    
    /** 
    Creates a CardViewElement from WCElementType. You may not make any assumptions about the size after this call.
    
    Use only for initialization
    */
    open class func createCardViewElement(_ type:WCElementType)->CardViewElement{
        
        var cardViewElement:CardViewElement!
        
        switch(type){
        case .fullHeader:
            cardViewElement = UIView.loadFromNibNamed("FullCardHeader") as! FullCardHeader
        case .twitterHeader:
            cardViewElement = UIView.loadFromNibNamed("TwitterHeader") as! TwitterHeader
        case .imageAndCaption:
            cardViewElement = UIView.loadFromNibNamed("ImageAndCaptionBody") as! ImageAndCaptionBody
        case .imageOnly:
            cardViewElement = ImageOnlyBody(frame:CGRect.zero);
        case .mediaTextFullWebView:
            cardViewElement = UIView.loadFromNibNamed("MediaTextFullWebView") as! MediaTextFullWebView
        case .imageFloatRight:
            cardViewElement = UIView.loadFromNibNamed("ImageFloatRightBody") as! ImageFloatRightBody
        case .imageFloatLeft:
            cardViewElement = UIView.loadFromNibNamed("ImageFloatLeftBody") as! ImageFloatLeftBody
        case .readMoreFooter:
            cardViewElement = ReadMoreFooter(frame:CGRect.zero);
        case .viewOnWebFooter:
            cardViewElement = ViewOnWebCardFooter(frame:CGRect.zero);
        case .simpleParagraph:
            cardViewElement = SingleParagraphCardBody(frame:CGRect.zero);
        case .videoBody:
            cardViewElement = VideoCardBody(frame:CGRect.zero);
        case .videoThumbnailBody:
            cardViewElement = VideoCardThumbnail(frame:CGRect.zero);
        }
        return cardViewElement
    }
}
