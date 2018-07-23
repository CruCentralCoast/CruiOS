//
//  Missions.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 7/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class Missions: DatabaseObject {
    
    var name: String
    var description: String?
    var startDate: Date
    var imageLink: String
    @objc dynamic var image: UIImage?
    
    required init?(dict: NSDictionary) {
        guard let name = dict["name"] as? String,
            let startDate = dict["startDate"] as? Date,
            let imageLink = dict["imageLink"] as? String
        else {
            return nil
        }
        
        self.name = name
        self.startDate = startDate
        self.description = dict["discription"] as? String
        self.imageLink = imageLink
    }
}

