//
//  EmptyCardBack.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/16/14.
//
//

import Foundation

class EmptyCardBack : CardViewElement {
    
    var titleLabel:UILabel!
    
    override func initialize() {
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = NSTextAlignment.center
        addSubview(titleLabel)
        titleLabel.verticallyCenterToSuperView(0)
        titleLabel.horizontallyCenterToSuperView(0)
        titleLabel.font = WildcardSDK.cardTitleFont
        titleLabel.textColor = UIColor.white
        titleLabel.text = "The Back!"
        backgroundColor = UIColor.wildcardDarkBlue()
    }
}
