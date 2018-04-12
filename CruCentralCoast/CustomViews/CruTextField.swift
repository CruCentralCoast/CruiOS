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
    
    private enum TitleState {
        case onTop
        case placeholder
    }
    
    private var bottomLine: UIView!
    private let bottomLineColor: UIColor = UIColor.lightGray
    private var errorLabel: UILabel!
    private let errorTextColor: UIColor = UIColor.red
    private var errorText: String?
    private var titleLabel: UILabel!
    private var titleTransform: CGAffineTransform!
    private let titleTextColor: UIColor = UIColor(white: 0.8, alpha: 1)
    private let titleSmallScale: CGFloat = 0.7
    private let titleOffsetY: CGFloat = -20
    private let animationDuration: TimeInterval = 0.15
    private var titleState: TitleState = .placeholder
    
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
        
        self.errorLabel = UILabel()
        self.addSubview(self.errorLabel!)
        self.errorLabel.text = self.errorText
        self.errorLabel.textColor = self.errorTextColor
        self.errorLabel.font = UIFont.systemFont(ofSize: 10, weight: .thin)
        self.errorLabel.sizeToFit()
        self.errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.errorLabel.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel = UILabel()
        self.addSubview(self.titleLabel!)
        self.titleLabel.text = self.title
        self.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.titleLabel.textColor = self.titleTextColor
        self.titleLabel.sizeToFit()
        self.titleLabel.centerXAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Change the anchor point to make transform animation behave properly
        self.titleLabel.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        // Remove placeholder if it exists
        self.placeholder = nil
        
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }
    
    @objc private func editingDidBegin() {
        self.setError(nil)
        // Animate color
        UIView.animate(withDuration: self.animationDuration) {
            self.bottomLine.backgroundColor = self.tintColor
            self.titleLabel.textColor = self.tintColor
        }
        // Return if the textField is not empty
        if self.hasText { return }
        
        setTitleState(.onTop, animated: true)
    }
    
    @objc private func editingDidEnd() {
        // Animate color
        UIView.animate(withDuration: self.animationDuration) {
            self.bottomLine.backgroundColor = self.bottomLineColor
            self.titleLabel.textColor = self.titleTextColor
        }
        // Return if the textField is not empty
        if self.hasText { return }
        
        setTitleState(.placeholder, animated: true)
    }
    
    private func setTitleState(_ newState: TitleState, animated: Bool) {
        if self.titleState == newState { return }
        switch newState {
        case .onTop:
            // Animate the transform and keep track of the original transform
            self.titleTransform = self.titleLabel.transform
            UIView.animate(withDuration: animated ? self.animationDuration : 0) {
//                let xOffset = -self.titleLabel.bounds.width * (1-self.titleSmallScale) * 0.5
                self.titleLabel.transform = self.titleTransform.translatedBy(x: 0, y: self.titleOffsetY).scaledBy(x: self.titleSmallScale, y: self.titleSmallScale)
            }
        case .placeholder:
            // Animate the transform
            UIView.animate(withDuration: animated ? self.animationDuration : 0) {
                self.titleLabel.transform = self.titleTransform
            }
        }
        self.titleState = newState
    }
    
    func setText(_ text: String?) {
        self.text = text
        let isTextEmpty = text == nil || text!.isEmpty
        setTitleState(isTextEmpty ? .placeholder : .onTop, animated: false)
    }
    
    func setError(_ text: String?) {
        self.errorLabel.text = text
        let isTextEmpty = text == nil || text!.isEmpty
        self.errorLabel.alpha = isTextEmpty ? 0 : 1
    }
    
    func validateHasText() {
        if !self.hasText {
            self.setError("\(self.title) field cannot be empty")
        }
    }
}
