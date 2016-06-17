//
//  PhoneFormatter.swift
//  Cru
//
//  Created by Max Crane on 5/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class PhoneFormatter {
    static func parsePhoneNumber(phoneNum : String) -> String {
        
        if(phoneNum.characters.count == 14){
            // split by '-'
            let full = phoneNum.componentsSeparatedByString("-")
            let left = full[0]
            var areaCode = ""
            var threeDigits = ""
            var right = ""
        
        
            if(left.characters.count >= 5){
                // get area code from ()
                var index1 = left.startIndex.advancedBy(1)
                let delFirstParen = left.substringFromIndex(index1)
                let index2 = delFirstParen.startIndex.advancedBy(3)
                areaCode = delFirstParen.substringToIndex(index2)
                if(left.characters.count >= 9){
                    // get first three digits
                    index1 = left.startIndex.advancedBy(6)
                    threeDigits = left.substringFromIndex(index1)
                }
            }
        
            // get last four digits if they exist
            if(full.count == 2){
                right = full[1]
            }
        
        
            return areaCode + threeDigits + right
        }
        return phoneNum
    }
    
    static func unparsePhoneNumber(phoneNum: String) -> String{
        
        if(phoneNum.characters.count == 10){
        let str : NSMutableString = NSMutableString(string: phoneNum)
        str.insertString("(", atIndex: 0)
        str.insertString(")", atIndex: 4)
        str.insertString(" ", atIndex: 5)
        str.insertString("-", atIndex: 9)
        return str as String
        }
        return phoneNum
    }
}