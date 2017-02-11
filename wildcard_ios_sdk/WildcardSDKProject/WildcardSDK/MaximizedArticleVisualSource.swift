//
//  MaximizedArticleDataSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/18/14.
//
//

import Foundation


open class MaximizedArticleVisualSource : MaximizedCardViewVisualSource {
    
    var card:Card
    var body:MediaTextFullWebView!
    
    public init(card:Card){
        self.card = card
    }
    
    @objc open func applicationFrameEdgeInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.mediaTextFullWebView) as! MediaTextFullWebView
        }
        return body
    }
}
