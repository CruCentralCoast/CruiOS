//
//  CommunityGroupLeader.swift
//  Cru
//
//  This class represents the data for a Community Group Leader, to be used to store leader information
//  in Community Group objects.
//
//  Created by Erica Solum on 7/2/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
//use to parse community group data to and from keystone db
struct CommunityGroupLeaderKeys {
    static let name = "name"
    static let firstName = "first"
    static let lastName = "last"
    static let phone = "phone"
    static let email = "email"
}


class CommunityGroupLeader {
    
    // MARK: Properties
    let name: String!
    let phone: String!
    let email: String!
    
    init(_ dict: NSDictionary) {
        let nameDict = dict[CommunityGroupLeaderKeys.name] as! [String:String]
        
        name = nameDict[CommunityGroupLeaderKeys.firstName]! + " " + nameDict[CommunityGroupLeaderKeys.lastName]!
        phone = dict[CommunityGroupLeaderKeys.phone] as! String
        email = dict[CommunityGroupLeaderKeys.email] as! String
    }
    
}
