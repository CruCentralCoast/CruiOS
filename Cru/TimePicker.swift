//
//  TimePicker.swift
//  Cru
//
//  Created by Max Crane on 5/3/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import ActionSheetPicker_3_0

class TimePicker {
    static func pickTime(vc: UIViewController){
        let datePicker = ActionSheetDatePicker(title: "Time:", datePickerMode: UIDatePickerMode.Time, selectedDate: NSDate(), target: vc, action: "datePicked:", origin: vc.view.superview)
        datePicker.minuteInterval = 15
        datePicker.showActionSheetPicker()
    }
    
    static func pickDate(vc: UIViewController, handler: (Int, Int, Int)->()){
        let datePicker = ActionSheetDatePicker(title: "Date:", datePickerMode: UIDatePickerMode.Date, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            if let val = value as? NSDate{
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day,.Month,.Year], fromDate: val)
                
                let month = components.month
                let day = components.day
                let year = components.year
                
                handler(month, day, year)
            }
            
            
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: vc.view)
        
        
        datePicker.showActionSheetPicker()
    }
}