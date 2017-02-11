//
//  VideoCardShortFullVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 4/15/15.
//
//

import Foundation


open class VideoCardShortFullVisualSource : BaseVisualSource, CardViewVisualSource{
    
    var header:VideoCardBody!
    var body:FullCardHeader!
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.videoBody) as! VideoCardBody
            header.videoAspectRatio = 0.5625 // 16:9 default for videos
            header.contentEdgeInset = UIEdgeInsetsMake(0,0,0,0)
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            body.contentEdgeInset = UIEdgeInsetsMake(15, 15, 15, 15)
            body.title.numberOfLines = 2
            body.logo.isHidden = true
            body.hairline.isHidden = true
        }
        return body;
    }
}
