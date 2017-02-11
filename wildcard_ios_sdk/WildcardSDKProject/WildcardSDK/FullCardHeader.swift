//
//  FullCardHeader.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

@objc
open class FullCardHeader : CardViewElement
{
    /// Use this to change the vertical spacing between the kicker and title
    open var kickerSpacing:CGFloat{
        get{
            return kickerToTitleSpacing.constant
        }
        set{
            kickerToTitleSpacing.constant = newValue
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Content insets of card card content
    open var contentEdgeInset:UIEdgeInsets{
        get{
            return UIEdgeInsetsMake(kickerTopConstraint.constant, titleLeadingConstraint.constant, titleBottomConstraint.constant, titleTrailingConstraint.constant)
        }
        set{
            kickerTopConstraint.constant = newValue.top
            titleLeadingConstraint.constant = newValue.left
            titleTrailingConstraint.constant = newValue.right
            titleBottomConstraint.constant = newValue.bottom
            adjustLabelLayoutWidths()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBOutlet weak var logo: WCImageView!
    @IBOutlet weak open var kicker: UILabel!
    @IBOutlet weak open var title: UILabel!
    open var hairline:UIView!
    
    // MARK: Private
    @IBOutlet weak fileprivate var kickerToTitleSpacing: NSLayoutConstraint!
    @IBOutlet weak fileprivate var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var kickerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var titleLeadingConstraint: NSLayoutConstraint!
    
    override open func initialize() {
        logo.layer.cornerRadius = 3.0
        logo.layer.masksToBounds = true
        kicker.setDefaultKickerStyling()
        title.setDefaultTitleStyling()
        hairline = addBottomBorderWithWidth(1.0, color: UIColor.wildcardBackgroundGray())
        contentEdgeInset = UIEdgeInsetsMake(10, 15, 10, 45)
    }
    
    override open func adjustForPreferredWidth(_ cardWidth: CGFloat) {
        adjustLabelLayoutWidths()
    }
    
    override open func update(_ card:Card) {
        
        switch(card.type){
        case .article:
            let articleCard = card as! ArticleCard
            kicker.text = articleCard.creator.name
            title.text = articleCard.title
            if let url = articleCard.creator.favicon{
                logo.setImageWithURL(url,mode:.scaleAspectFit)
                logo.backgroundColor = UIColor.clear
            }
        case .summary:
            let summaryCard = card as! SummaryCard
            kicker.text = summaryCard.webUrl.host
            title.text = summaryCard.title
        case .video:
            let videoCard = card as! VideoCard
            kicker.text = videoCard.webUrl.host
            title.text = videoCard.title
            if let url = videoCard.creator.favicon{
                logo.setImageWithURL(url,mode:.scaleAspectFit)
                logo.backgroundColor = UIColor.clear
            }
        case .image:
            let imageCard = card as! ImageCard
            kicker.text = imageCard.creator.name
            title.text = imageCard.title
            if let url = imageCard.creator.favicon{
                logo.setImageWithURL(url,mode:.scaleAspectFit)
                logo.backgroundColor = UIColor.clear
            }
        case .unknown:
            title.text = "Unknown Card Type"
            kicker.text = "Unknown Card Type"
        }
    }
    
    override open func optimizedHeight(_ cardWidth:CGFloat)->CGFloat{
        
        var height:CGFloat = 0
        height += kickerTopConstraint.constant
        height += kicker.font.lineHeight
        height += kickerToTitleSpacing.constant
        
        height += Utilities.fittedHeightForLabel(title, labelWidth: cardWidth - titleLeadingConstraint.constant - titleTrailingConstraint.constant)
  
        height += titleBottomConstraint.constant
        
        return round(height)
    }
    
    fileprivate func adjustLabelLayoutWidths(){
        // preferred width affects preferred layout widths of labels
        title.preferredMaxLayoutWidth = preferredWidth - titleLeadingConstraint.constant - titleTrailingConstraint.constant
        kicker.preferredMaxLayoutWidth = preferredWidth - titleLeadingConstraint.constant - titleTrailingConstraint.constant
    }
    
}
