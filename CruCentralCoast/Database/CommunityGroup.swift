//
//  CommunityGroup.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 7/19/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityGroup: NSObject,DatabaseObject {
    
    var dayOfWeek: String?
    var leaderDescription: String
    var gender: String
    var type: String
    var name: String
    //var leaders: [String]
    var imageLink: String
    @objc dynamic var image: UIImage?
    
    required init?(dict: NSDictionary) {
        guard let leaderDescription = dict["description"] as? String,
            let gender = dict["gender"] as? String,
            //let leaders = dict["leaders"] as? [String],
            let type = dict["type"] as? String,
            let name = dict["name"] as? String,
            let imageLink = dict["imageLink"] as? String
        else {
            return nil
        }
        
        self.leaderDescription = leaderDescription
        self.gender = gender
        //self.leaders = leaders
        self.type = type
        self.name = name
        self.imageLink = imageLink
        self.dayOfWeek = dict["dayOfWeek"] as? String
        
    }
}
