//
//  NSObject+Additions.swift
//  Cru
//
//  Created by Tyler Dahl on 7/9/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
