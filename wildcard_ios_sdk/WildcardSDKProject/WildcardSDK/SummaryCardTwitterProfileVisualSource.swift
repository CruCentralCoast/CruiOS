//
//  SummaryCardTwitterProfileVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 4/23/15.
//
//

import Foundation


open class SummaryCardTwitterProfileVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:ImageOnlyBody!
    var body:TwitterHeader!
    var footer:SingleParagraphCardBody!
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(.imageOnly) as! ImageOnlyBody
            header.contentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(.twitterHeader) as! TwitterHeader
        }
        return body
    }
    
    @objc open func viewForCardFooter() -> CardViewElement? {
        if(footer == nil){
            footer = CardViewElementFactory.createCardViewElement(.simpleParagraph) as! SingleParagraphCardBody
            footer.contentEdgeInset = UIEdgeInsetsMake(0, 20, 22, 20)
            footer.paragraphLabel.textColor = UIColor.wildcardDarkBlue()
            footer.paragraphLabel.font = UIFont(name:"HelveticaNeue-Light", size: 18.0)!
        }
        return footer
        
    }
}
