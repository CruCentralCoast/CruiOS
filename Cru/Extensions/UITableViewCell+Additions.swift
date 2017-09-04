//
//  UITableViewCell+Additions.swift
//  Cru
//
//  Created by Tyler Dahl on 7/9/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var cellReuseIdentifier: String {
        return self.className
    }
}
