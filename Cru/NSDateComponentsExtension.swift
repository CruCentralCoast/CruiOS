//
//  NSDateComponentsExtension.swift
//  Cru
//
//  An extension for NSDateComponents that returns formatted String representations of the Date.
//
//  Created by Quan Tran on 2/11/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

struct MonthNames {
    static let FULL:NSDictionary = [
        1 : "January",
        2 : "February",
        3 : "March",
        4 : "April",
        5 : "May",
        6 : "June",
        7 : "July",
        8 : "August",
        9 : "September",
        10 : "October",
        11 : "November",
        12 : "December"
    ]
    
    
    static let SHORT:NSDictionary = [
        1 : "Jan",
        2 : "Feb",
        3 : "Mar",
        4 : "Apr",
        5 : "May",
        6 : "Jun",
        7 : "Jul",
        8 : "Aug",
        9 : "Sep",
        10 : "Oct",
        11 : "Nov",
        12 : "Dec"
    ]

}

extension NSDateComponents {
    /** Returns a MM-DD-YYYY representaton of the date using the default separator. */
    func formatMDY() -> String {
        return formatMDY(" ")
    }
    
    /** Returns a MM-DD-YYYY representaton of the date using the given separator. */
    func formatMDY(separator : String) -> String {
        return String(self.month) + separator + String(self.month) + separator + String(self.year)
    }
    
    /** Returns a YYYY-MM-DD representaton of the date using the default separator. */
    func formatYMD() -> String {
        return formatYMD(" ")
    }
    
    /** Returns a YYYY-MM-DD representaton of the date using the given separator. */
    func formatYMD(separator: String) -> String {
        return String(self.year) + separator + String(self.month) + separator + String(self.day)
    }
    
    /** Returns a HH:MM representaton of the time. */
    func formattedTime() -> String {
        return String(self.hour) + ":" + String(self.minute)
    }
    
    /** Returns a MONTH DD representation of the date */
    func formatMonthDay() -> String {
        return String(MonthNames.SHORT[self.month]!) + " " + String(self.day)
    }
    
    /** Returns a MONTH DD Year representation of the date */
    func formatMonthDayYear() -> String {
        return formatMonthDay() + ", " + String(self.year)
    }
}