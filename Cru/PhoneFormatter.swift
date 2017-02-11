//
//  PhoneFormatter.swift
//  Cru
//
//  Created by Max Crane on 5/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class PhoneFormatter {
    static func parsePhoneNumber(_ phoneNum : String) -> String {
        
        if(phoneNum.characters.count == 14){
            // split by '-'
            let full = phoneNum.components(separatedBy: "-")
            let left = full[0]
            var areaCode = ""
            var threeDigits = ""
            var right = ""
        
        
            if(left.characters.count >= 5){
                // get area code from ()
                var index1 = left.characters.index(left.startIndex, offsetBy: 1)
                let delFirstParen = left.substring(from: index1)
                let index2 = delFirstParen.characters.index(delFirstParen.startIndex, offsetBy: 3)
                areaCode = delFirstParen.substring(to: index2)
                if(left.characters.count >= 9){
                    // get first three digits
                    index1 = left.characters.index(left.startIndex, offsetBy: 6)
                    threeDigits = left.substring(from: index1)
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
    
    static func unparsePhoneNumber(_ phoneNum: String) -> String{
        
        if(phoneNum.characters.count == 10){
        let str : NSMutableString = NSMutableString(string: phoneNum)
        str.insert("(", at: 0)
        str.insert(")", at: 4)
        str.insert(" ", at: 5)
        str.insert("-", at: 9)
        return str as String
        }
        return phoneNum
    }
}
