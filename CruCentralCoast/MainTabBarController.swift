//
//  MainTabBarController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    static let tabBarChangedString = "tabBarChanged"
    static let tabBarChangedNotification = Notification.Name(MainTabBarController.tabBarChangedString)
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // this works since self.selectedIndex isn't updated until after this call
        if self.selectedIndex != tabBar.items?.index(of: item) {
            NotificationCenter.default.post(name: MainTabBarController.tabBarChangedNotification, object: self)
        }
    }

}
