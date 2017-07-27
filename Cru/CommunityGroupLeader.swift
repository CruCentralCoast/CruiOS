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


class CommunityGroupLeader: NSObject, NSCoding {
    
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
    
    init?(name: String, phone: String, email: String) {
        self.name = name
        self.phone = phone
        self.email = email
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let phone = aDecoder.decodeObject(forKey: "phone") as? String,
            let email = aDecoder.decodeObject(forKey: "email") as? String
            else { return nil }
        
        
        self.init(
            name: name, phone: phone, email: email
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.email, forKey: "email")
    }
    
}
