//
//  SummaryCardTwitterTweetVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 4/23/15.
//
//

import Foundation


open class SummaryCardTwitterTweetVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:TwitterHeader!
    var body:SingleParagraphCardBody!
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(.twitterHeader) as! TwitterHeader
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(.simpleParagraph) as! SingleParagraphCardBody
            body.contentEdgeInset = UIEdgeInsetsMake(0, 20, 22, 20)
            body.paragraphLabel.textColor = UIColor.wildcardDarkBlue()
            body.paragraphLabel.font = UIFont(name:"HelveticaNeue-Light", size: 18.0)!
        }
        return body
    }
}
