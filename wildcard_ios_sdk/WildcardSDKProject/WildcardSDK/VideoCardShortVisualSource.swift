//
//  VideoCardShortVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/9/15.
//
//

import Foundation


open class VideoCardShortImageSource : BaseVisualSource, CardViewVisualSource{
    
    var header:FullCardHeader!
    var body:VideoCardBody!
    
    @objc open func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.fullHeader) as! FullCardHeader
            header.hairline.isHidden = true
            header.contentEdgeInset = UIEdgeInsetsMake(10, 15, 10, 45)
            header.title.numberOfLines = 3
        }
        return header
    }
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(WCElementType.videoBody) as! VideoCardBody
            body.videoAspectRatio = 0.5625 // 16:9 default for videos
            body.contentEdgeInset = UIEdgeInsetsMake(0, 15, 15, 15)
        }
        return body;
    }
}
