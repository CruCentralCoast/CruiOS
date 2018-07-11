//
//  DateExtensions.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

public extension Date {
    func toString( dateFormat format : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
