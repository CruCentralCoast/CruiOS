//
//  CruImageButton.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@IBDesignable
class CruImageButton: UIButton {
    
    @IBInspectable
    var cornerRadius: CGFloat = -1 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    var imageColor: UIColor = UIColor.clear {
        didSet {
            self.imageView?.tintColor = self.imageColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Customizations
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.setImage(self.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.imageView?.tintColor = (self.imageColor == UIColor.clear) ? self.currentTitleColor : self.imageColor
        self.layer.cornerRadius = (self.cornerRadius >= 0) ? self.cornerRadius : self.bounds.height / 2
    }
}
