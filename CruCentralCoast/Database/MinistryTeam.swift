//
//  MinistryTeam.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 7/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MinistryTeam: DatabaseObject {
    
    var name: String
    //var leaders: [String]
    var description: String?
    var imageLink: String?
    @objc dynamic var image: UIImage?
    
    required init?(dict: NSDictionary) {
        guard let name = dict["name"] as? String
        //let leaders = dict["leaders"] as? [String]
        else {
            return nil
        }
        
        self.name = name
        //self.leaders = leaders
        self.description = dict["discription"] as? String
        self.imageLink = dict["teamImageLink"] as? String
    }
}

