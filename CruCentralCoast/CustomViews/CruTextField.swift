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
    var title: String = "Title" {
        didSet {
            self.titleLabel?.text = self.title
        }
    }
    
    private var bottomLine: UIView!
    private let bottomLineColor: UIColor = UIColor.lightGray
    private var titleLabel: UILabel!
    private var titleTransform: CGAffineTransform!
    private let titleTextColor: UIColor = UIColor(white: 0.8, alpha: 1)
    private let titleSmallScale: CGFloat = 0.7
    private let titleOffsetY: CGFloat = -20
    private let animationDuration: TimeInterval = 0.15
    
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
        self.bottomLine.backgroundColor = self.bottomLineColor
        self.bottomLine.layer.cornerRadius = 2
        self.bottomLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        self.bottomLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel = UILabel()
        self.addSubview(self.titleLabel!)
        self.titleLabel.text = self.title
        self.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel.textColor = self.titleTextColor
        self.titleLabel.sizeToFit()
        self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove placeholder if it exists
        self.placeholder = nil
        
        self.addTarget(self, action: #selector(editingDidBegin), for: UIControlEvents.editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: [UIControlEvents.editingDidEnd, .editingDidEndOnExit])
    }
    
    @objc func editingDidBegin() {
        // Animate color
        UIView.animate(withDuration: self.animationDuration) {
            self.bottomLine.backgroundColor = self.tintColor
            self.titleLabel.textColor = self.tintColor
        }
        // Return if the textField is empty
        if let text = self.text, !text.isEmpty { return }
        // Animate the transform and keep track of the original transform
        self.titleTransform = self.titleLabel.transform
        UIView.animate(withDuration: self.animationDuration) {
            let xOffset = -self.titleLabel.bounds.width * (1-self.titleSmallScale) * 0.5
            self.titleLabel.transform = self.titleTransform.translatedBy(x: xOffset, y: self.titleOffsetY).scaledBy(x: self.titleSmallScale, y: self.titleSmallScale)
        }
    }
    
    @objc func editingDidEnd() {
        // Animate color
        UIView.animate(withDuration: self.animationDuration) {
            self.bottomLine.backgroundColor = self.bottomLineColor
            self.titleLabel.textColor = self.titleTextColor
        }
        // Return if the textField is empty
        if let text = self.text, !text.isEmpty { return }
        // Animate the transform
        UIView.animate(withDuration: self.animationDuration) {
            self.titleLabel.transform = self.titleTransform
        }
    }
}
