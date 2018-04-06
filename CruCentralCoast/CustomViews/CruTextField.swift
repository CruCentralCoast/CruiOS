//
//  CruTextField.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@IBDesignable
class CruTextField: UITextField {
    
    @IBInspectable
    var lineColor: UIColor = UIColor.lightGray {
        didSet {
            self.bottomLine?.backgroundColor = self.lineColor
        }
    }
    
    private var bottomLine: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.bottomLine = UIView()
        self.addSubview(self.bottomLine!)
        self.bottomLine?.backgroundColor = self.lineColor
        self.bottomLine?.layer.cornerRadius = 2
        self.bottomLine?.heightAnchor.constraint(equalToConstant: 2).isActive = true
        self.bottomLine?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.bottomLine?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.bottomLine?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.bottomLine?.translatesAutoresizingMaskIntoConstraints = false
    }
}
