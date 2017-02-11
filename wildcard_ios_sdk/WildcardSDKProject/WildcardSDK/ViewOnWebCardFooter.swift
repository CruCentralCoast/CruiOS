//
//  ViewOnWebFooter.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

@objc
open class ViewOnWebCardFooter: CardViewElement {
    
    open var viewOnWebButton:UIButton!
    open var shareButton:UIButton!
    open var hairline:UIView!
    
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(topConstraint.constant, leftConstraint.constant, bottomConstraint.constant, rightConstraint.constant)
        }
        set{
            topConstraint.constant = newValue.top
            leftConstraint.constant = newValue.left
            rightConstraint.constant = newValue.right
            bottomConstraint.constant = newValue.bottom
        }
    }
    
    // MARK: Private
    fileprivate var topConstraint:NSLayoutConstraint!
    fileprivate var bottomConstraint:NSLayoutConstraint!
    fileprivate var leftConstraint:NSLayoutConstraint!
    fileprivate var rightConstraint:NSLayoutConstraint!
    
    override open func initialize() {
        viewOnWebButton = UIButton.defaultViewOnWebButton()
        addSubview(viewOnWebButton!)
        leftConstraint = viewOnWebButton?.constrainLeftToSuperView(15)
        topConstraint = viewOnWebButton?.constrainTopToSuperView(10)
        bottomConstraint = viewOnWebButton?.constrainBottomToSuperView(10)
        
        hairline = addTopBorderWithWidth(0.5, color: UIColor.wildcardBackgroundGray())
        viewOnWebButton.addTarget(self, action: #selector(ViewOnWebCardFooter.viewOnWebButtonTapped), for: .touchUpInside)
        
        shareButton = UIButton(frame: CGRect.zero)
        shareButton.tintColor = UIColor.wildcardLightBlue()
        shareButton.setImage(UIImage.loadFrameworkImage("shareIcon"), for: UIControlState())
        addSubview(shareButton)
        rightConstraint = shareButton.constrainRightToSuperView(15)
        
        addConstraint(NSLayoutConstraint(item: shareButton, attribute: .centerY, relatedBy: .equal, toItem: viewOnWebButton, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        shareButton.addTarget(self, action: #selector(ViewOnWebCardFooter.shareButtonTapped), for: .touchUpInside)
        
        //Added 7-8-16 for Cru Central Coast by Erica Solum
        shareButton.isHidden = true
    }
    
    func shareButtonTapped(){
        if(cardView != nil){
            WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"shareAction"], with: cardView!.backingCard)
            cardView!.handleShare()
        }
    }
    
    func viewOnWebButtonTapped(){
        if(cardView != nil){
            WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"viewOnWeb"], with: cardView!.backingCard)
            cardView!.handleViewOnWeb(cardView!.backingCard.webUrl)
        }
    }
    
    override open func adjustForPreferredWidth(_ cardWidth: CGFloat) {
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0
        height += topConstraint.constant
        height += viewOnWebButton.intrinsicContentSize.height
        height += bottomConstraint.constant
        return round(height)
    }
}
