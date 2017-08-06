//
//  User.swift
//  Cru
//
//  Created by Deniz Tumer on 11/29/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class User: Codable {

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
