//
//  TallReadMoreCardFooter.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

@objc
open class ReadMoreFooter: CardViewElement {
    
    /// Read More Button. Always left aligned at the moment.
    open var readMoreButton:UIButton!
    
    /// Content insets. Right inset for this element does nothing at the moment.
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(topConstraint.constant, leftConstraint.constant, bottomConstraint.constant, 0)
        }
        set{
            leftConstraint.constant = newValue.left
            bottomConstraint.constant = newValue.bottom
            topConstraint.constant = newValue.top
        }
    }
    
    // MARK: Private
    fileprivate var leftConstraint:NSLayoutConstraint!
    fileprivate var topConstraint:NSLayoutConstraint!
    fileprivate var bottomConstraint:NSLayoutConstraint!
    
    override open func initialize() {
        readMoreButton = UIButton.defaultReadMoreButton()
        addSubview(readMoreButton!)
        
        leftConstraint = readMoreButton?.constrainLeftToSuperView(15)
        topConstraint = readMoreButton?.constrainTopToSuperView(10)
        bottomConstraint = readMoreButton?.constrainBottomToSuperView(10)
        
        readMoreButton.addTarget(self, action: #selector(ReadMoreFooter.readMoreButtonTapped), for: UIControlEvents.touchUpInside)
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        var height:CGFloat = 0
        height += topConstraint.constant
        height += readMoreButton.intrinsicContentSize.height
        height += bottomConstraint.constant
        return round(height)
    }
    
    override open func adjustForPreferredWidth(_ cardWidth: CGFloat) {
    }
    
    func readMoreButtonTapped(){
        WildcardSDK.analytics?.trackEvent("CardEngaged", withProperties: ["cta":"readMore"], with: cardView?.backingCard)
        if(cardView != nil){
            cardView!.delegate?.cardViewRequestedAction?(cardView!, action: CardViewAction(type: .maximize, parameters: nil))
        }
    }
}
