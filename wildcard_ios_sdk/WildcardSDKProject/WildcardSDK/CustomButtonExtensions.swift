//
//  CustomButtons.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/16/15.
//
//

import Foundation

extension UIButton {
    class func defaultViewOnWebButton() -> UIButton{
        let viewOnWebButton = UIButton(type: UIButtonType.custom)
        viewOnWebButton.styleAsExternalLink("VIEW ON WEB")
        return viewOnWebButton
    }
    
    func styleAsExternalLink(_ text:String){
        
        let buttonTitle = NSMutableAttributedString(string: text)
        buttonTitle.setKerning(0.3)
        buttonTitle.setFont(WildcardSDK.cardActionButtonFont)
        buttonTitle.setColor(UIColor.wildcardLightBlue())
        buttonTitle.setUnderline(NSUnderlineStyle.styleSingle)
        
        let highlightTitle = NSMutableAttributedString(attributedString: buttonTitle)
        highlightTitle.setColor(UIColor.wildcardDarkBlue())
        
        setAttributedTitle(buttonTitle, for: UIControlState())
        setAttributedTitle(highlightTitle, for: .highlighted)
    }
    
    class func defaultReadMoreButton()->UIButton{
        
        let readMoreButton = UIButton(type: UIButtonType.custom)
        readMoreButton.setBackgroundImage(UIImage.loadFrameworkImage("borderedButtonBackground"), for: UIControlState())
        readMoreButton.setBackgroundImage(UIImage.loadFrameworkImage("borderedButtonBackgroundTapped"), for: UIControlState.highlighted)
        readMoreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        let buttonTitle = NSMutableAttributedString(string: "READ MORE")
        buttonTitle.setFont(WildcardSDK.cardActionButtonFont)
        buttonTitle.setColor(UIColor.wildcardLightBlue())
        buttonTitle.setKerning(0.3)
        
        let highlightedTitle = NSMutableAttributedString(attributedString: buttonTitle)
        highlightedTitle.setColor(UIColor.wildcardDarkBlue())
        
        readMoreButton.setAttributedTitle(buttonTitle, for: UIControlState())
        readMoreButton.setAttributedTitle(highlightedTitle, for: .highlighted)
        readMoreButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
        
        return readMoreButton
    }
}
