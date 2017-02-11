//
//  TwitterHeader.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 4/23/15.
//
//

import Foundation

@objc
open class TwitterHeader : CardViewElement
{
    @IBOutlet weak var twitterIcon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var kicker: UILabel!
    
    /// Content insets of card card content
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(topConstraint.constant, leadingConstraint.constant, bottomConstraint.constant, trailingConstraint.constant)
        }
        set{
            topConstraint.constant = newValue.top
            leadingConstraint.constant = newValue.left
            trailingConstraint.constant = newValue.right
            bottomConstraint.constant = newValue.bottom
            invalidateIntrinsicContentSize()
        }
    }
 
    // MARK: Private
    @IBOutlet weak fileprivate var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var topConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var twitterIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var twitterIconWidthConstraint: NSLayoutConstraint!
    
    override open func initialize() {
        twitterIcon.tintColor = UIColor.twitterBlue()
        
        title.textColor = WildcardSDK.cardTitleColor
        title.font = UIFont(name:"HelveticaNeue-Medium", size: 14.0)!
        title.numberOfLines = 1
        kicker.textColor = WildcardSDK.cardKickerColor
        kicker.numberOfLines = 1
        kicker.font = UIFont(name:"HelveticaNeue-Light", size: 12.0)!
        
        contentEdgeInset = UIEdgeInsetsMake(20, 20, 20, 20)
    }
    
    override open func update(_ card:Card) {
        if(card.type == WCCardType.summary){
            let summaryCard = card as! SummaryCard
            title.text = summaryCard.title
            if let subtitle = summaryCard.subtitle{
                kicker.text = "@\(subtitle)"
            }else{
                kicker.text = summaryCard.webUrl.host!
            }
        }else{
            print("This header element is not supported for type \(card.cardType) yet")
        }
    }
    
    override open func optimizedHeight(_ cardWidth: CGFloat) -> CGFloat {
        var height:CGFloat = 0
        height += topConstraint.constant
        height += twitterIconHeightConstraint.constant
        height += bottomConstraint.constant
        return height
    }
    
}
