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

class User: NSObject, NSCoding {

    let name: String!
    let phone: String!
    let email: String!
    
    init(dict: NSDictionary) {
        let nameDict = dict["name"] as! [String:String]
        name = nameDict["first"]! + " " + nameDict["last"]!
        phone = dict["phone"] as! String
        email = dict["email"] as! String
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.phone = aDecoder.decodeObject(forKey: "phone") as! String
        self.email = aDecoder.decodeObject(forKey: "email") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.email, forKey: "email")
    }
}
