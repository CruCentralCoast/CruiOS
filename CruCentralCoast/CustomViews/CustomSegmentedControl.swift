//
//  CustomSegmentedControl.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0
    
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
        self.selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: self.frame.height))
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
        // without this line, the "self.frame.width" was only
        // 375 on the iphone 8 Plus, not 414
        self.updateView()
        
        self.layer.cornerRadius = self.frame.height/2
    }
    
    @objc func buttonTapped(sender: UIButton) {
        for (idx, button) in self.buttons.enumerated() {
            button.setTitleColor(self.textColor, for: .normal)
            if button == sender {
                self.selectedSegmentIndex = idx
                let selectorStartPosition = self.frame.width/CGFloat(self.buttons.count) * CGFloat(idx)
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosition
                })
                
                button.setTitleColor(self.selectorTextColor, for: .normal)
            }
        }
        self.sendActions(for: .valueChanged)
    }
    
}

