//
//  VideoCardThumbnail.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/27/15.
//
//

import Foundation

@objc
open class VideoCardThumbnail : CardViewElement, WCVideoViewDelegate {
    
    open var videoView:WCVideoView!
    open var title:UILabel!
    open var kicker:UILabel!
    
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
    
    /// Use this to change the vertical spacing between the kicker and title
    open var kickerSpacing:CGFloat{
        get{
            return kickerToTitleSpacing.constant
        }
        set{
            kickerToTitleSpacing.constant = newValue
        }
    }
    
    /// Use this to change the horizontal padding between the label and the video view
    open var labelToVideoPadding:CGFloat{
        get{
            return labelToVideoViewPadding.constant
        }
        set{
            labelToVideoViewPadding.constant = newValue;
            adjustForPreferredWidth(preferredWidth)
        }
    }
    
    fileprivate var topConstraint:NSLayoutConstraint!
    fileprivate var leftConstraint:NSLayoutConstraint!
    fileprivate var rightConstraint:NSLayoutConstraint!
    fileprivate var bottomConstraint:NSLayoutConstraint!
    fileprivate var videoHeightConstraint:NSLayoutConstraint!
    fileprivate var videoWidthConstraint:NSLayoutConstraint!
    fileprivate var kickerToTitleSpacing: NSLayoutConstraint!
    fileprivate var labelToVideoViewPadding:NSLayoutConstraint!
    
    override open func initialize() {
        
        // wildcard video view
        videoView = WCVideoView(frame:CGRect.zero)
        videoView.delegate = self
        addSubview(videoView)
        rightConstraint = videoView.constrainRightToSuperView(15)
        topConstraint = videoView.constrainTopToSuperView(15)
        bottomConstraint = videoView.constrainBottomToSuperView(15)
        videoWidthConstraint = videoView.constrainWidth(120)
        videoWidthConstraint.priority = 999
        videoHeightConstraint = videoView.constrainHeight(90)
        videoHeightConstraint.priority = 999
        
        kicker = UILabel(frame: CGRect.zero)
        kicker.setDefaultKickerStyling()
        addSubview(kicker)
        leftConstraint = kicker.constrainLeftToSuperView(15)
        kicker.alignTopToView(videoView)
        labelToVideoViewPadding = NSLayoutConstraint(item: videoView, attribute: .left, relatedBy: .equal, toItem: kicker, attribute: .right, multiplier: 1.0, constant: 15)
        addConstraint(labelToVideoViewPadding)
        
        title = UILabel(frame:CGRect.zero)
        title.setDefaultTitleStyling()
        addSubview(title)
        kickerToTitleSpacing = NSLayoutConstraint(item: title, attribute: .top, relatedBy: .equal, toItem: kicker, attribute: .bottom, multiplier: 1.0, constant: 3)
        addConstraint(kickerToTitleSpacing)
        title.alignLeftToView(kicker)
        title.alignRightToView(kicker)
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0.0
        height += topConstraint.constant
        height += videoHeightConstraint.constant
        height += bottomConstraint.constant
        return height
    }
    
    override open func update(_ card:Card) {
        if let videoCard = card as? VideoCard{
            videoView.loadVideoCard(videoCard)
            kicker.text = videoCard.creator.name
            title.text = videoCard.title
            updateLabelAttributes()
        }else{
            print("VideoCardThumbnail element should only be used with a video card.")
        }
    }
    
    fileprivate func updateLabelAttributes(){
        
        // the space available for the labels in this element
        let labelPreferredWidth = preferredWidth -
            rightConstraint.constant -
            leftConstraint.constant -
            videoWidthConstraint.constant -
            labelToVideoViewPadding.constant
        
        kicker.preferredMaxLayoutWidth = labelPreferredWidth
        title.preferredMaxLayoutWidth = labelPreferredWidth
        title.setRequiredNumberOfLines(labelPreferredWidth, maxHeight: videoHeightConstraint.constant - kicker.font.lineHeight - kickerToTitleSpacing.constant)
        invalidateIntrinsicContentSize()
    }
    
    open override func adjustForPreferredWidth(_ cardWidth: CGFloat) {
        updateLabelAttributes()
    }
    
    // MARK: WCVideoViewDelegate
    open func videoViewTapped(_ videoView: WCVideoView) {
        WildcardSDK.analytics?.trackEvent("CardEngagement", withProperties: ["cta":"videoTapped"], with:cardView?.backingCard)
    }
    
    open func videoViewDidStartPlaying(_ videoView: WCVideoView) {
        if(cardView != nil){
            cardView!.delegate?.cardViewRequestedAction?(cardView!, action: CardViewAction(type: .videoDidStartPlaying, parameters:nil))
        }
    }
    
    open func videoViewWillEndPlaying(_ videoView: WCVideoView) {
        if(cardView != nil){
            cardView!.delegate?.cardViewRequestedAction?(cardView!, action: CardViewAction(type: .videoWillEndPlaying, parameters:nil))
        }
    }
}
