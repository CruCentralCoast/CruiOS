//
//  DateExtensions.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

public extension Date {
    
    func toString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}
