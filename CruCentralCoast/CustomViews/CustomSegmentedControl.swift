//
//  CruSegmentedControl.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@IBDesignable
class CruSegmentedControl: UIControl {
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0 {
        didSet {
            self.updateIndex(self.selectedSegmentIndex)
        }
    }
    var isAnimating = false
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.lightGray {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
    
    @IBInspectable
    var commaSeparatedButtonTitles: String = "" {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .lightGray {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = .darkGray {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable
    var selectorTextColor: UIColor = .white {
        didSet {
            self.updateView()
        }
    }
    
    private func updateView() {
        self.buttons.removeAll()
        self.subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = self.commaSeparatedButtonTitles.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(self.textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            self.buttons.append(button)
        }
        
        self.buttons[0].setTitleColor(self.selectorTextColor, for: .normal)
        
        let selectorWidth = self.frame.width/CGFloat(buttonTitles.count)
        self.selector = UIView(frame: CGRect(x: 0, y: self.borderWidth, width: selectorWidth, height: self.frame.height - 2*self.borderWidth))
        self.selector.layer.cornerRadius = self.frame.height/2
        self.selector.backgroundColor = self.selectorColor
        self.addSubview(self.selector)
        
        let stackView = UIStackView(arrangedSubviews: self.buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        // this line is here because of a simulator glitch which bases sizes of things off of the storyboard "View As (device)" option
        // for release, I don't think this line will be necesary
        self.updateView()
        
        self.layer.cornerRadius = (self.frame.height-2*self.borderWidth)/2
    }
    
    @objc func buttonTapped(sender: UIButton) {
        for (idx, button) in self.buttons.enumerated() {
            if button == sender {
                self.selectedSegmentIndex = idx
                return
            }
        }
    }
    
    func updateSelectorPosition(offset: CGFloat) {
        if !self.isAnimating {
            self.selector.frame.origin.x = offset/CGFloat(self.buttons.count)
        }
        let selectorWidth = self.frame.width/CGFloat(buttons.count)
        let centerOfSelector = self.selector.frame.origin.x + selectorWidth/2
        for button in self.buttons {
            // is the selector between me and another button? (within a certain ammount)
            let centerOfButton = button.frame.origin.x + button.frame.width/2
            if centerOfButton - selectorWidth ... centerOfButton + selectorWidth ~= centerOfSelector {
                let fraction = abs(centerOfButton-centerOfSelector)/selectorWidth
                button.setTitleColor(self.selectorTextColor.interpolateRGBColorTo(self.textColor, fraction: fraction), for: .normal)
            }
        }
    }
    
    private func updateIndex(_ index: Int) {
        for (idx, button) in self.buttons.enumerated() {
            button.setTitleColor(self.textColor, for: .normal)
            if idx == index {
                let selectorStartPosition = self.frame.width/CGFloat(self.buttons.count) * CGFloat(idx)
                self.isAnimating = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosition
                }) { (completed) in
                    self.isAnimating = false
                }
                
                button.setTitleColor(self.selectorTextColor, for: .normal)
            }
        }
        self.sendActions(for: .valueChanged)
    }
}

