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
    static func pickTime(_ vc: UIViewController){
        let datePicker = ActionSheetDatePicker(title: "Time:", datePickerMode: UIDatePickerMode.time, selectedDate: Date(), target: vc, action: "datePicked:", origin: vc.view.superview)
        datePicker?.minuteInterval = 15
        datePicker?.show()
    }
    
    static func pickDate(_ vc: UIViewController, handler: @escaping (Int, Int, Int)->()){
        let datePicker = ActionSheetDatePicker(title: "Date:", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
            picker, value, index in
            
            if let val = value as? Date{
                let calendar = Calendar.current
                let components = (calendar as NSCalendar).components([.day,.month,.year], from: val)
                
                let month = components.month
                let day = components.day
                let year = components.year
                
                handler(month!, day!, year!)
            }
            
            
            return
            }, cancel: { ActionStringCancelBlock in return }, origin: vc.view)
        
        
        datePicker?.show()
    }
}
