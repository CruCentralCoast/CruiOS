//
//  CenteredImageBody.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

@objc
open class ImageOnlyBody : CardViewElement, WCImageViewDelegate{
    
    open var imageView:WCImageView!
    
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
    
    /// Content insets
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(topConstraint.constant, leftConstraint.constant, bottomConstraint.constant, rightConstraint.constant)
        }
        set{
            topConstraint.constant = newValue.top
            leftConstraint.constant = newValue.left
            rightConstraint.constant = newValue.right
            bottomConstraint.constant = newValue.bottom
            
            //needs re adjust if content insets change
            adjustForPreferredWidth(preferredWidth)
        }
    }
    
    fileprivate var topConstraint:NSLayoutConstraint!
    fileprivate var leftConstraint:NSLayoutConstraint!
    fileprivate var rightConstraint:NSLayoutConstraint!
    fileprivate var bottomConstraint:NSLayoutConstraint!
    fileprivate var imageHeightConstraint:NSLayoutConstraint!
    fileprivate var imageWidthConstraint:NSLayoutConstraint!
    fileprivate var __imageAspectRatio:CGFloat = 0.75
    
    override open func initialize(){
        
        imageView = WCImageView(frame: CGRect.zero)
        imageView.delegate = self
        addSubview(imageView)
        
        leftConstraint = imageView.constrainLeftToSuperView(10)
        rightConstraint = imageView.constrainRightToSuperView(10)
        topConstraint = imageView.constrainTopToSuperView(10)
        bottomConstraint = imageView.constrainBottomToSuperView(10)
        
        imageWidthConstraint = imageView.constrainWidth(0)
        imageWidthConstraint.priority = 999
        imageHeightConstraint = imageView.constrainHeight(0)
        imageHeightConstraint.priority = 999
    }
    
    open override func adjustForPreferredWidth(_ cardWidth: CGFloat) {
        imageWidthConstraint.constant = cardWidth - leftConstraint.constant - rightConstraint.constant
        imageHeightConstraint.constant = round(imageWidthConstraint.constant * imageAspectRatio)
        invalidateIntrinsicContentSize()
    }
    
    override open func update(_ card:Card) {
        
        var imageUrl:URL?
        
        switch(card.type){
        case .article:
            let articleCard = card as! ArticleCard
            imageUrl = articleCard.primaryImageURL as URL?
        case .summary:
            let webLinkCard = card as! SummaryCard
            imageUrl = webLinkCard.primaryImageURL as URL?
        case .image:
            let imageCard = card as! ImageCard
            imageUrl = imageCard.imageUrl as URL
        case .unknown, .video:
            imageUrl = nil
        }
        
        // download image
        if let url = imageUrl {
            imageView.setImageWithURL(url, mode: .scaleAspectFill)
        }
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0.0
        height += topConstraint.constant
        height += imageHeightConstraint.constant
        height += bottomConstraint.constant
        return height
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
