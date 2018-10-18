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

extension Person: DatabasePath {
    static var databasePath: String = "users"
}

extension Campus: DatabasePath {
    static var databasePath: String = "campuses"
}

extension Movement: DatabasePath {
    static var databasePath: String = "movements"
}

extension Event: DatabasePath {
    static var databasePath: String = "events"
}

extension CommunityGroup: DatabasePath {
    static var databasePath: String = "communitygroups"
}

extension MinistryTeam: DatabasePath {
    static var databasePath: String = "ministryteams"
}

extension Mission: DatabasePath {
    static var databasePath: String = "missions"
}

extension Resource: DatabasePath {
    static var databasePath: String = "resources"
}
