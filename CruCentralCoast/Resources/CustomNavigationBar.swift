//
//  CustomNavigationBar.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//
//  Credit to https://github.com/ShawnBaek/Custom-UIKit-NavigationBar
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    
    //set NavigationBar's height
    var customHeight : CGFloat = 150
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if #available(iOS 11, *) {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
//
//        let v = UIView()
//        v.backgroundColor = .green
//        self.addSubview(v)
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        v.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        v.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        v.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {

        return CGSize(width: UIScreen.main.bounds.width, height: customHeight)

    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let y = UIApplication.shared.statusBarFrame.height
        self.frame = CGRect(x: frame.origin.x, y:  y, width: frame.size.width, height: customHeight)
        for subview in self.subviews {
            var stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
                subview.backgroundColor = self.backgroundColor
            }

            stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarContent") {
                subview.frame = CGRect(x: subview.frame.origin.x, y: 20, width: subview.frame.width, height: customHeight)
                subview.backgroundColor = self.backgroundColor

            }
        }
    }
}
