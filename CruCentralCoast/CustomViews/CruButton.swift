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
    
    private var originalTransform: CGAffineTransform!
    private var originalTitleColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // Animations
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Customizations
        self.layer.cornerRadius = (self.cornerRadius >= 0) ? self.cornerRadius : self.bounds.height / 2
    }
    
    @objc private func touchDown() {
        self.originalTransform = self.transform
        self.originalTitleColor = self.currentTitleColor
        UIView.animate(withDuration: 0.1) {
            self.transform = self.transform.scaledBy(x: 0.95, y: 0.95)
            self.setTitleColor(self.originalTitleColor.withAlphaComponent(0.7), for: .normal)
        }
    }
    
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = self.originalTransform
            self.setTitleColor(self.originalTitleColor, for: .normal)
        }
    }
}
