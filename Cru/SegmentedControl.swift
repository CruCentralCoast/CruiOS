//
//  SegmentedControl.swift
//  Cru
//
//  Created by Erica Solum on 7/20/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SegmentedControl: UIControl {
    fileprivate var labels = [UILabel]()
    var thumbView = UIView()
    
    var items:[String] = ["Round Trip", "To Event", "From Event"] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    var inactiveGray = UIColor(red: 149/225, green: 147/225, blue: 145/225, alpha: 1.0)
    
    //Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        thumbView.backgroundColor = CruColors.lightBlue
        thumbView.layer.cornerRadius = thumbView.frame.height / 5
        
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count - 1 {
            let label = labels[index]
            
            let xPos = CGFloat(index) * labelWidth
            label.frame = CGRect(x: xPos, y: 0, width: labelWidth, height: labelHeight)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex: Int?
        
        for(index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
            
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    
    //Setup the view
    func setupView() {
        layer.cornerRadius = frame.height / 5
        layer.borderColor = CruColors.lightBlue.cgColor
        layer.borderWidth = 1
        
        backgroundColor = UIColor.clear
        setupLabels()
        insertSubview(thumbView, at: 0)
    }
    
    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...items.count {
            let label = UILabel(frame: CGRect.zero)
            label.text = items[index - 1]
            label.textAlignment = .center
            print("\nindex: \(index)")
            
            label.textColor = CruColors.lightBlue
            
            if index-1 == selectedIndex {
                label.textColor = UIColor.white
            }
            
            label.font = UIFont(name: Config.fontBold, size: 14)
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    func resetLabelColors() {
        for label in labels {
            label.textColor = CruColors.lightBlue
        }
    }
    
    func displayNewSelectedIndex() {
        resetLabelColors()
        let label = labels[selectedIndex]
        
        
        //self.thumbView.frame = label.frame
        
        UIView.animate(withDuration: 0.4, animations: {
            self.thumbView.frame = label.frame
            label.textColor = UIColor.white
        })
    }
    
    func getDirection() -> String {
        switch selectedIndex {
        case 0:
            return "both"
        case 1:
            return "to"
        case 2:
            return "from"
        default:
            return "both"
        }
    }
}
