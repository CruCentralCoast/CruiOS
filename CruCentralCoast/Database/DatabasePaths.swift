//
//  DatabasePaths.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 5/9/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

@objc protocol DatabasePath {
    static var databasePath: String { get }
}

extension Campus: DatabasePath {
    static var databasePath: String = "campus"
}

extension Ministry: DatabasePath {
    static var databasePath: String = "ministries"
}

extension Movement: DatabasePath {
    static var databasePath: String = "ministries"
}

extension Resource: DatabasePath {
    static var databasePath: String = "resources"
}

extension Event: DatabasePath {
    static var databasePath: String = "events"
}
