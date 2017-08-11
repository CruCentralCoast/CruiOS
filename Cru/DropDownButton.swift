//
//  DropDownButton.swift
//  Cru
//
//  Created by Erica Solum on 8/10/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class DropDownButton: UIButton {
    
    // source: https://github.com/AssistoLab/DropDown

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = CruColors.lightBlue
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        view.addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: 1
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1,
            constant: 0
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .right,
            relatedBy: .equal,
            toItem: self,
            attribute: .right,
            multiplier: 1,
            constant: 0
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
            )
        )
    }

}
