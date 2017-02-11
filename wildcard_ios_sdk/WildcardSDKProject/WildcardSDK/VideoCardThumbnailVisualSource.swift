//
//  VideoCardThumbnailVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/27/15.
//
//

import Foundation


open class VideoCardThumbnailImageSource : BaseVisualSource, CardViewVisualSource{
    
    var body:VideoCardThumbnail!
    var back:SingleParagraphCardBody!
    
    @objc open func viewForCardBody()->CardViewElement{
        if(body == nil){
            body = CardViewElementFactory.createCardViewElement(.videoThumbnailBody) as! VideoCardThumbnail
        }
        return body;
    }
    
    @objc open func viewForBackOfCard() -> CardViewElement? {
        if(back == nil){
            back = CardViewElementFactory.createCardViewElement(WCElementType.simpleParagraph) as! SingleParagraphCardBody
        }
        return back;
    }
}
