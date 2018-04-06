//
//  CruButton.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@IBDesignable
class CruButton: UIButton {
    
    @IBInspectable
    var cornerRadius: CGFloat = -1 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Customizations
        self.layer.cornerRadius = (self.cornerRadius >= 0) ? self.cornerRadius : self.bounds.height / 2
    }
}
