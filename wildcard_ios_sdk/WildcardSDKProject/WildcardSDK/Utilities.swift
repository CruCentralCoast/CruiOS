//
//  Utilities.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//
//

import Foundation

/// Public Bag of Tricks
open class Utilities{
    
    // MARK: Public
    open class var IS_IPAD: Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }
    open class var IS_IPHONE: Bool {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
    }
    open class var IS_RETINA: Bool {
        return UIScreen.main.scale >= 2.0
    }
    open class var SCREEN_WIDTH:CGFloat{
        return UIScreen.main.bounds.size.width;
    }
    open class var SCREEN_HEIGHT:CGFloat{
        return UIScreen.main.bounds.size.height;
    }
    open class var SCREEN_MAX_LENGTH:CGFloat{
        return max(SCREEN_HEIGHT, SCREEN_WIDTH)
    }
    open class var SCREEN_MAIN_LENGTH:CGFloat{
        return min(SCREEN_HEIGHT, SCREEN_WIDTH)
    }
    open class var IS_IPHONE_4_OR_LESS:Bool{
        return IS_IPHONE && SCREEN_MAX_LENGTH < 568.0
    }
    open class var IS_IPHONE_5:Bool{
        return IS_IPHONE && SCREEN_MAX_LENGTH == 568.0
    }
    open class var IS_IPHONE_6:Bool{
        return IS_IPHONE && SCREEN_MAX_LENGTH == 667.0
    }
    open class var IS_IPHONE_6P:Bool{
        return IS_IPHONE && SCREEN_MAX_LENGTH == 736.0
    }
    
    /// Prints the font families available
    open class func printFontFamilies(){
        for name in UIFont.familyNames
        {
            print("Font family: \(name)")
            let names = UIFont.fontNames(forFamilyName: name)
            print(names)
        }
    }
    
    /// Get the height required for a specific text string, with a max height
    open class func heightRequiredForText(_ text:String?, lineHeight:CGFloat, font:UIFont, width:CGFloat, maxHeight:CGFloat)->CGFloat{
        if(text == nil){
            return 0
        }else{
            let nsStr = NSString(string: text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            let attributesDictionary:[String: AnyObject] =
            [NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName:font]
            
            let bounds =
            nsStr.boundingRect(with: CGSize(width: width,
                height: maxHeight),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: attributesDictionary,
                context: nil)
            return bounds.size.height;
        }
    }
    
    /// Get the height required for a specific text string with unbounded height
    open class func heightRequiredForText(_ text:String?, lineHeight:CGFloat, font:UIFont, width:CGFloat)->CGFloat{
        return Utilities.heightRequiredForText(text, lineHeight: lineHeight, font: font, width: width, maxHeight: CGFloat.greatestFiniteMagnitude)
    }
    
    /// Gets the fitted height for a label given a specific width
    open class func fittedHeightForLabel(_ label:UILabel, labelWidth:CGFloat)->CGFloat{
        
        var titleHeight:CGFloat = 0
        if(label.numberOfLines == 0){
            // unbounded height
            titleHeight = Utilities.heightRequiredForText(label.text, lineHeight: label.font.lineHeight, font: label.font, width: labelWidth)
        }else{
            // set number of lines, must cap the height
            let maxHeight:CGFloat = CGFloat(label.numberOfLines) * label.font.lineHeight
            titleHeight = Utilities.heightRequiredForText(label.text, lineHeight: label.font.lineHeight, font: label.font, width: labelWidth, maxHeight:maxHeight)
        }
        return titleHeight
        
    }
}
