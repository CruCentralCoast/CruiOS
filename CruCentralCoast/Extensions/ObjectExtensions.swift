//
//  ObjectExtensions.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

extension NSObject {
    func className() -> String {
        return String(describing: type(of: self))
    }
}
