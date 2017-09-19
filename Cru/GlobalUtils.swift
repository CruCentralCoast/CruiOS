//
//  GlobalUtils.swift
//  Cru
//
//  Created by Deniz Tumer on 3/4/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import ImageLoader

class GlobalUtils {
    
    class PhoneRes {
        var shouldChange = false
        var newText = ""
    }
    
    
    class func stringFromLocation(_ location: NSDictionary?) -> String {
        var locStr = ""
        
        if let loc = location {
            if let street = loc["street1"] {
                locStr += street as! String
            }
            if let city = loc["suburb"] {
                locStr += " " + (city as! String)
            }
            if let state = loc["state"] {
                locStr += ", " + (state as! String)
            }
        }
        
        return locStr
    }
    
    class func setupViewForSideMenu(_ view: UIViewController, menuButton :UIBarButtonItem){
        if view.revealViewController() != nil{
            menuButton.target = view.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.view.addGestureRecognizer(view.revealViewController().panGestureRecognizer())
            view.view.addGestureRecognizer(view.revealViewController().tapGestureRecognizer())
            if let vc = view as? SWRevealViewControllerDelegate{
                view.revealViewController().delegate = vc
            }
        }
    }
    
    class func getDefaultDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return dateFormatter
    }
    
    class func getCommunityGroupsDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter
    }
    
    //gets an NSDate from a given string
    class func dateFromString(_ dateStr: String) -> Date {
        let dateFormatter = getDefaultDateFormatter()
        
        //if date formatter returns nil return the current date/time
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        else {
            return Date()
        }
    }
        
    //return appropriate string representation of NSDate object
    class func stringFromDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    //returns default date as it is in the database
    class func stringFromDate(_ date: Date) -> String {
        let formatter = getDefaultDateFormatter()
        
        return formatter.string(from: date)
    }
    
    //gets date components from an NSDate
    class func dateComponentsFromDate(_ date: Date) -> DateComponents? {
        let unitFlags: NSCalendar.Unit = [.minute, .hour, .day, .month, .year]
        
        return (Calendar.current as NSCalendar).components(unitFlags, from: date)
    }
    
    //load dictionary object from user defaults
    class func loadDictionary(_ key: String) -> NSDictionary? {
        let userDefaults = UserDefaults.standard
        
        if let unarchivedObject = userDefaults.object(forKey: key) {
            return unarchivedObject as? NSDictionary
        }
        
        return nil
    }
    
    class func saveString(_ key: String, value: String){
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: value)
        let defaults = UserDefaults.standard
        defaults.set(archivedObject, forKey: key)
        defaults.synchronize()
    }
    
    class func loadString(_ key: String)->String{
        if let unarchivedObject = UserDefaults.standard.object(forKey: key) as? Data {
            let token = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? String
            return token!
        }
        return ""
    }
    
    class func saveBool(_ key: String, value: Bool){
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: value)
        let defaults = UserDefaults.standard
        defaults.set(archivedObject, forKey: key)
        defaults.synchronize()
    }
    
    class func loadBool(_ key: String)-> Bool{
        if let unarchivedObject = UserDefaults.standard.object(forKey: key) as? Data {
            let token = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? Bool
            return token!
        }
        return false
    }
    
    class func printRequest(_ params: AnyObject) {
        do {
            let something = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            let string1 = NSString(data: something, encoding: String.Encoding.utf8.rawValue)
            //print(string1)
        } catch {
            print("Error writing json body")
        }
    }
    
    class func parsePhoneNumber(_ phoneNum : String) -> String {
        // split by '-'
        let full = phoneNum.components(separatedBy: "-")
        let left = full[0]
        let right = full[1]
        
        // get area code from ()
        var index1 = left.characters.index(left.startIndex, offsetBy: 1)
        let delFirstParen = left.substring(from: index1)
        let index2 = delFirstParen.characters.index(delFirstParen.startIndex, offsetBy: 3)
        let areaCode = delFirstParen.substring(to: index2)
        
        // get first three digits
        index1 = left.characters.index(left.startIndex, offsetBy: 6)
        let threeDigits = left.substring(from: index1)
        
        // get last four digits
        // = right
        
        let finalPhoneNum = areaCode + threeDigits + right
        return finalPhoneNum
        
    }
    
    static func shouldChangeNameTextInRange(_ fieldText: String, range: NSRange, text: String)-> Bool {
        let currentCharacterCount = fieldText.characters.count
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= 50
    }
    
    
    static func shouldChangePhoneTextInRange(_ num : String, range: NSRange, replacementText: String)-> PhoneRes {
        let res = PhoneRes()
        res.newText = num
        
        let newString = (num as NSString).replacingCharacters(in: range, with: replacementText)
        let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        
        let decimalString = components.joined(separator: "") as NSString
        let length = decimalString.length
        let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
        
        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
            let newLength = (num as NSString).length + (replacementText as NSString).length - range.length as Int
            res.shouldChange = (newLength > 10) ? false : true
            return res
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne {
            formattedString.append("1 ")
            index += 1
        }
        if (length - index) > 3 {
            let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 3 {
            let prefix = decimalString.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalString.substring(from: index)
        formattedString.append(remainder)
        
        res.newText = formattedString as String
        res.shouldChange = false
        
        return res
    }
    
    //formats a phone number
    static func formatPhoneNumber(_ phoneNo: String) -> String {
        var retPhoneNo: String = "("
        
        for ndx in 0..<phoneNo.characters.count {
            let charIndex = phoneNo.characters.index(phoneNo.startIndex, offsetBy: ndx)
            
            retPhoneNo.append(phoneNo[charIndex])
            
            if ndx == 2 {
                retPhoneNo += ") "
            }
            else if ndx == 5 {
                retPhoneNo += "-"
            }
        }
        
        return retPhoneNo
    }
}
