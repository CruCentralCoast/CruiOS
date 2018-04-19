//
//  UIStoryboardExtensions.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 4/7/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    func instantiateViewController<T: UIViewController>(_ classType: T.Type) -> T {
        let identifier = String(describing: T.self)
        guard let viewController = self.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("The instantiated view controller is not an instance of \(identifier).")
        }
        return viewController
    }
}
