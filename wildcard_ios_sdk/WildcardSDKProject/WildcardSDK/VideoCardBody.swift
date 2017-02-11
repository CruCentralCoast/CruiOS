//
//  VideoCardBody.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/9/15.
//
//

import Foundation
import MediaPlayer
import WebKit

/// A Card Body which can play various Video Cards
@objc
open class VideoCardBody : CardViewElement, WCVideoViewDelegate{
    
    open var videoView:WCVideoView!
    
    /// Adjusts the aspect ratio of the video
    open var videoAspectRatio:CGFloat{
        get{
            return __videoAspectRatio
        }
        set{
            __videoAspectRatio = newValue
            videoHeightConstraint.constant = round(videoWidthConstraint.constant * __videoAspectRatio)
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
    fileprivate var videoHeightConstraint:NSLayoutConstraint!
    fileprivate var videoWidthConstraint:NSLayoutConstraint!
    fileprivate var __videoAspectRatio:CGFloat = 0.75
   
    override open func initialize(){
        
        // wildcard video view
        videoView = WCVideoView(frame:CGRect.zero)
        videoView.delegate = self
        addSubview(videoView)
        leftConstraint = videoView.constrainLeftToSuperView(10)
        rightConstraint = videoView.constrainRightToSuperView(10)
        topConstraint = videoView.constrainTopToSuperView(10)
        bottomConstraint = videoView.constrainBottomToSuperView(10)
        videoWidthConstraint = videoView.constrainWidth(0)
        videoWidthConstraint.priority = 999
        videoHeightConstraint = videoView.constrainHeight(0)
        videoHeightConstraint.priority = 999
    }
    
    open override func adjustForPreferredWidth(_ cardWidth: CGFloat) {
        videoWidthConstraint.constant = cardWidth - leftConstraint.constant - rightConstraint.constant
        videoHeightConstraint.constant = round(videoWidthConstraint.constant * __videoAspectRatio)
        invalidateIntrinsicContentSize()
    }
    
    override open func update(_ card:Card) {
        if let videoCard = card as? VideoCard{
            videoView.loadVideoCard(videoCard)
        }else{
            print("VideoCardBody element should only be used with a video card.")
        }
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0.0
        height += topConstraint.constant
        height += videoHeightConstraint.constant
        height += bottomConstraint.constant
        return height
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
