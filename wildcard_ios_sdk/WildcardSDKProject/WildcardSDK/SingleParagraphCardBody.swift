//
//  SingleParagraphCardBody.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

/**
Most basic card body consisting of just a paragraph label
*/
@objc
open class SingleParagraphCardBody : CardViewElement {
    
    open var paragraphLabel:UILabel!
    
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(topConstraint.constant, leftConstraint.constant, bottomConstraint.constant, rightConstraint.constant)
        }
        set{
            topConstraint.constant = newValue.top
            leftConstraint.constant = newValue.left
            rightConstraint.constant = newValue.right
            bottomConstraint.constant = newValue.bottom
            
            adjustForPreferredWidth(preferredWidth)
        }
    }
    
    fileprivate var topConstraint:NSLayoutConstraint!
    fileprivate var leftConstraint:NSLayoutConstraint!
    fileprivate var rightConstraint:NSLayoutConstraint!
    fileprivate var bottomConstraint:NSLayoutConstraint!
    
    override open func initialize() {
        backgroundColor = UIColor.white
        
        paragraphLabel = UILabel(frame: CGRect.zero)
        paragraphLabel.setDefaultDescriptionStyling()
        paragraphLabel.textAlignment = NSTextAlignment.left
        paragraphLabel.numberOfLines = 0
        addSubview(paragraphLabel)
        leftConstraint = paragraphLabel.constrainLeftToSuperView(10)
        rightConstraint = paragraphLabel.constrainRightToSuperView(10)
        topConstraint = paragraphLabel.constrainTopToSuperView(5)
        bottomConstraint = paragraphLabel.constrainBottomToSuperView(5)
        
    }
    
    override open func adjustForPreferredWidth(_ cardWidth: CGFloat) {
        paragraphLabel.preferredMaxLayoutWidth = cardWidth - leftConstraint.constant - rightConstraint.constant
        invalidateIntrinsicContentSize()
    }
    
    override open func update(_ card:Card) {
        
        switch(card.type){
        case .article:
            let articleCard = card as! ArticleCard
            paragraphLabel.text = articleCard.abstractContent
        case .summary:
            let webLinkCard = card as! SummaryCard
            paragraphLabel.text = webLinkCard.abstractContent
        case .video:
            let videoCard = card as! VideoCard
            paragraphLabel.text = videoCard.abstractContent
        case .image:
            let imageCard = card as! ImageCard
            paragraphLabel.text = imageCard.imageCaption
        case .unknown:
            paragraphLabel.text = "Unknown Card Type"
        }
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0
        height += topConstraint.constant
        
        height += Utilities.fittedHeightForLabel(paragraphLabel, labelWidth: cardWidth - leftConstraint.constant - rightConstraint.constant)
        
        height += bottomConstraint.constant
        return round(height)
    }
    
 
}
