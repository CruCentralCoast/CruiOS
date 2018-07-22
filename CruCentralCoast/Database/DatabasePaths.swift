//
//  DatabasePaths.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 5/9/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

protocol DatabasePath {
    static var databasePath: String { get }
}

extension Ministry: DatabasePath {
    static var databasePath: String = "ministries"
}

extension CommunityGroup: DatabasePath {
    static var databasePath: String = "communitygroups"
}

extension Resource: DatabasePath {
    static var databasePath: String = "resources"
}

extension Event: DatabasePath {
    static var databasePath: String = "events"
}
