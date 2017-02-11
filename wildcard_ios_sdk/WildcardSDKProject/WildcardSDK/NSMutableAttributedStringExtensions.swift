//
//  NSMutableAttributedStringExtensions.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/9/14.
//
//

import Foundation

extension NSMutableAttributedString{
    
    func setLineHeight(_ height:CGFloat){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight =  height
        paragraphStyle.maximumLineHeight =  height
        
        self.addAttribute(NSParagraphStyleAttributeName,
            value: paragraphStyle,
            range: NSMakeRange(0, self.string.characters.count))
    }
    
    func setFont(_ font:UIFont){
        self.addAttribute(NSFontAttributeName,
            value: font,
            range: NSMakeRange(0, self.string.characters.count))
    }
    
    func setColor(_ color:UIColor){
        self.addAttribute(NSForegroundColorAttributeName,
            value: color,
            range: NSMakeRange(0, self.string.characters.count))
    }
    
    func setKerning(_ kerning:Float){
        self.addAttribute(NSKernAttributeName, value: NSNumber(value: kerning as Float), range: NSMakeRange(0, self.string.characters.count))
        
    }
    
    func setUnderline(_ style:NSUnderlineStyle){
        self.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(value: style.rawValue as Int), range: NSMakeRange(0,self.string.characters.count))
    }
}

