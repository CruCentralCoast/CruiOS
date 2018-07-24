//
//  Ministry.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class Ministry: DatabaseObject {

    var name: String
    var description: String?
    var imageLink: String?
        
    required init?(dict: NSDictionary) {
        guard let name = dict["name"] as? String else {
            return nil
        }
        self.name = name
        self.description = dict["discription"] as? String
        self.imageLink = dict["imageLink"] as? String
    }
}
