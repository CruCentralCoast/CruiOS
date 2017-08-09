//
//  User.swift
//  Cru
//
//  Created by Deniz Tumer on 11/29/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit


//use to parse user data to and from keystone db
struct UserKeys {
    static let id = "_id"
    static let phone = "phone"
    static let email = "email"
    static let notifications = "notifications"
    static let summerMissionsUpdates = "summerMissionUpdates"
    static let communityGroupUpdates = "communityGroupUpdates"
    static let ministryTeamUpdates = "ministryTeamUpdates"
    static let isCommunityGroupLeader = "isCommunityGroupLeader"
    static let isMinistryTeamLeader = "isMinistryTeamLeader"
    static let isSummerMissionLeader = "isSummerMissionLeader"
    
}

class User {

    let name: String!
    let phone: String!
    let email: String!
    
    init(dict: NSDictionary) {
        let nameDict = dict["name"] as! [String:String]
        name = nameDict["first"]! + " " + nameDict["last"]!
        phone = dict["phone"] as! String
        email = dict["email"] as! String
    }
}
