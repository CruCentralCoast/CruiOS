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
    
    
    class func stringFromLocation(location: NSDictionary?) -> String {
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
    
    class func setupViewForSideMenu(view: UIViewController, menuButton :UIBarButtonItem){
        if view.revealViewController() != nil{
            menuButton.target = view.revealViewController()
            menuButton.action = "revealToggle:"
            view.view.addGestureRecognizer(view.revealViewController().panGestureRecognizer())
            if let vc = view as? SWRevealViewControllerDelegate{
                view.revealViewController().delegate = vc
            }
        }
    }
    
    class func getDefaultDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return dateFormatter
    }
    
    //gets an NSDate from a given string
    class func dateFromString(dateStr: String) -> NSDate {
        let dateFormatter = getDefaultDateFormatter()
        
        //if date formatter returns nil return the current date/time
        if let date = dateFormatter.dateFromString(dateStr) {
            return date
        }
        else {
            return NSDate()
        }
    }
        
    //return appropriate string representation of NSDate object
    class func stringFromDate(date: NSDate, format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        
        return formatter.stringFromDate(date)
    }
    
    //returns default date as it is in the database
    class func stringFromDate(date: NSDate) -> String {
        let formatter = getDefaultDateFormatter()
        
        return formatter.stringFromDate(date)
    }
    
    //gets date components from an NSDate
    class func dateComponentsFromDate(date: NSDate) -> NSDateComponents? {
        let unitFlags: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
        
        return NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
    }
    
    //load dictionary object from user defaults
    class func loadDictionary(key: String) -> NSDictionary? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let unarchivedObject = userDefaults.objectForKey(key) {
            return unarchivedObject as? NSDictionary
        }
        
        return nil
    }
    
    class func saveString(key: String, value: String){
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(value)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: key)
        defaults.synchronize()
    }
    
    class func loadString(key: String)->String{
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData {
            let token = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? String
            return token!
        }
        return ""
    }
    
    class func printRequest(params: AnyObject) {
        do {
            let something = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            let string1 = NSString(data: something, encoding: NSUTF8StringEncoding)
            print(string1)
        } catch {
            print("Error writing json body")
        }
    }
    
    class func parsePhoneNumber(phoneNum : String) -> String {
        // split by '-'
        let full = phoneNum.componentsSeparatedByString("-")
        let left = full[0]
        let right = full[1]
        
        // get area code from ()
        var index1 = left.startIndex.advancedBy(1)
        let delFirstParen = left.substringFromIndex(index1)
        let index2 = delFirstParen.startIndex.advancedBy(3)
        let areaCode = delFirstParen.substringToIndex(index2)
        
        // get first three digits
        index1 = left.startIndex.advancedBy(6)
        let threeDigits = left.substringFromIndex(index1)
        
        // get last four digits
        // = right
        
        let finalPhoneNum = areaCode + threeDigits + right
        return finalPhoneNum
        
    }
    
    static func shouldChangeNameTextInRange(fieldText: String, range: NSRange, text: String)-> Bool {
        let currentCharacterCount = fieldText.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= 50
    }
    
    
    static func shouldChangePhoneTextInRange(num : String, range: NSRange, replacementText: String)-> PhoneRes {
        let res = PhoneRes()
        res.newText = num
        
        let newString = (num as NSString).stringByReplacingCharactersInRange(range, withString: replacementText)
        let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        
        let decimalString = components.joinWithSeparator("") as NSString
        let length = decimalString.length
        let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
        
        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
            let newLength = (num as NSString).length + (replacementText as NSString).length - range.length as Int
            res.shouldChange = (newLength > 10) ? false : true
            return res
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne {
            formattedString.appendString("1 ")
            index += 1
        }
        if (length - index) > 3 {
            let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("(%@) ", areaCode)
            index += 3
        }
        if length - index > 3 {
            let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalString.substringFromIndex(index)
        formattedString.appendString(remainder)
        
        res.newText = formattedString as String
        res.shouldChange = false
        
        return res
    }
    
    //formats a phone number
    static func formatPhoneNumber(phoneNo: String) -> String {
        var retPhoneNo: String = "("
        
        for ndx in 0..<phoneNo.characters.count {
            let charIndex = phoneNo.startIndex.advancedBy(ndx)
            
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
