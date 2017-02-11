//
//  ImageWithCaption.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/16/15.
//
//

import Foundation

/**
Card Body with an image and a caption under it.
*/
@objc
open class ImageAndCaptionBody : CardViewElement, WCImageViewDelegate{
    
    @IBOutlet weak open var imageView: WCImageView!
    @IBOutlet weak open var caption: UILabel!
    
    /// Adjusts the aspect ratio of the image view.
    open var imageAspectRatio:CGFloat{
        get{
            return __imageAspectRatio
        }
        set{
            __imageAspectRatio = newValue
            imageHeightConstraint.constant = round(imageWidthConstraint.constant * __imageAspectRatio)
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Content inset for image view and caption
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(imageTopConstraint.constant, imageLeftConstraint.constant, captionBottomConstraint.constant, imageRightConstraint.constant)
        }
        set{
            imageTopConstraint.constant = newValue.top
            imageLeftConstraint.constant = newValue.left
            imageRightConstraint.constant = newValue.right
            captionBottomConstraint.constant = newValue.bottom
            
            imageWidthConstraint.constant = preferredWidth - imageLeftConstraint.constant - imageRightConstraint.constant
            imageHeightConstraint.constant = round(imageWidthConstraint.constant * imageAspectRatio)
            caption.preferredMaxLayoutWidth = imageWidthConstraint.constant
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Controls the spacing between the caption and the image
    open var captionSpacing:CGFloat{
        get{
            return captionTopConstraint.constant
        }
        set{
            captionTopConstraint.constant = newValue
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBOutlet weak fileprivate var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var captionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var captionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var imageRightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var imageLeftConstraint: NSLayoutConstraint!
    fileprivate var __imageAspectRatio:CGFloat = 0.75
    
    override open func initialize(){
        caption.setDefaultDescriptionStyling()
        
        // not ready to constrain height yet, set to 0 to get rid of
        imageHeightConstraint.constant = 0
        imageView.delegate = self
    }
    
    override open func update(_ card:Card) {
        
        var imageUrl:URL?
        
        switch(card.type){
        case .article:
            let articleCard = card as! ArticleCard
            imageUrl = articleCard.primaryImageURL as URL?
            caption.text = articleCard.abstractContent
        case .summary:
            let summaryCard = card as! SummaryCard
            imageUrl = summaryCard.primaryImageURL as URL?
            caption.text = summaryCard.abstractContent
        case .unknown, .video, .image:
            imageUrl = nil
        }
        
        // download image
        if imageUrl != nil {
            imageView.setImageWithURL(imageUrl!, mode:.scaleAspectFill)
        }
    }
    
    override open func adjustForPreferredWidth(_ cardWidth: CGFloat) {
        imageWidthConstraint.constant = cardWidth - imageLeftConstraint.constant - imageRightConstraint.constant
        imageHeightConstraint.constant = round(imageWidthConstraint.constant * imageAspectRatio)
        caption.preferredMaxLayoutWidth = imageWidthConstraint.constant
        invalidateIntrinsicContentSize()
    }
    
    override open var intrinsicContentSize : CGSize {
        let size =  CGSize(width: preferredWidth, height: optimizedHeight(preferredWidth))
        return size
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0.0
        
        height += imageTopConstraint.constant
        height += imageHeightConstraint.constant
        height += captionTopConstraint.constant
        
        height += Utilities.fittedHeightForLabel(caption, labelWidth: imageWidthConstraint.constant)
        
        height += captionBottomConstraint.constant
        return round(height)
    }
    
    // MARK: WCImageViewDelegate
    open func imageViewTapped(_ imageView: WCImageView) {
        WildcardSDK.analytics?.trackEvent("CardEngagement", withProperties: ["cta":"imageTapped"], with:cardView?.backingCard)
        
        if(cardView != nil){
            let parameters = NSMutableDictionary()
            parameters["tappedImageView"] = imageView
            cardView!.delegate?.cardViewRequestedAction?(cardView!, action: CardViewAction(type: .imageTapped, parameters: parameters))
        }
    }
}
