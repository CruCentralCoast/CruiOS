//
//  UIColorExtensions.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/29/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

public extension UIColor {
    static var appTint: UIColor {
        return .cruOrange
    }
    
    static var cruGold: UIColor {
        return UIColor(red: 249/255.0, green: 182/255.0, blue: 37/255.0, alpha: 1)
    }
    
    static var cruOrange: UIColor {
        return UIColor(red: 221/255.0, green: 125/255.0, blue: 27/255.0, alpha: 1)
    }
    
    static var cruBrightBlue: UIColor {
        return UIColor(red: 62/255.0, green: 177/255.0, blue: 200/255.0, alpha: 1)
    }
    
    static var cruDeepBlue: UIColor {
        return UIColor(red: 0, green: 115/255.0, blue: 152/255.0, alpha: 1)
    }
    
    static var cruGray: UIColor {
        return UIColor(red: 102/255.0, green: 96/255.0, blue: 98/255.0, alpha: 1)
    }
    
    static var navBarLineGray: UIColor {
        return UIColor(red: 206/255.0, green: 206/255.0, blue: 206/255.0, alpha: 1)
    }
    
    static var appleGray: UIColor {
        return UIColor(red: 240/255.0, green: 240/255.0, blue: 247/255.0, alpha: 1)
    }
    
    // Credit to https://stackoverflow.com/questions/22868182/uicolor-transition-based-on-progress-value/24687720#24687720
    func interpolateRGBColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor? {
        let f = min(max(0, fraction), 1)
        
        guard let c1 = self.cgColor.components, let c2 = end.cgColor.components else { return nil }
        
        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
