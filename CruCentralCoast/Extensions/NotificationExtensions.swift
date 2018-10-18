//
//  NotificationExtensions.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 8/31/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static var UserDidLogin: NSNotification.Name { return NSNotification.Name("UserDidLogin") }
    static var UserDidLogout: NSNotification.Name { return NSNotification.Name("UserDidLogout") }
}
