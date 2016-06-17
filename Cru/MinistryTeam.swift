//
//  MinistryTeam.swift
//  Cru
//
//  Created by Deniz Tumer on 3/2/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeam {
    var id: String
    var parentMinistry: String
    var description: String
    var ministryName: String
    var image: UIImage!
    var imageUrl: String
    var teamImage: UIImage!
    var teamImageUrl: String
    var leaders: [User]
    
    init?(dict: NSDictionary) {
        //required initialization of variables
        self.id = ""
        self.parentMinistry = ""
        self.ministryName = ""
        self.description = ""
        self.image = UIImage(named: "event1")
        self.imageUrl = ""
        self.teamImage = UIImage(named: "event1")
        self.teamImageUrl = ""
        self.leaders = [User]()
        
        //grabbing dictionary values
        let dId = dict.objectForKey("_id")
        let dParentMinistry = dict.objectForKey("parentMinistry")
        let dDescription = dict.objectForKey("description")
        let dMinistryName = dict.objectForKey("name")
        let dImage = dict.objectForKey("leadersImage")
        let dLeaders = dict.objectForKey("leaders")
        
        //set up object
        if (dId != nil) {
            self.id = dId as! String
        }
        if (dParentMinistry != nil) {
            self.parentMinistry = dParentMinistry as! String
        }
        if (dDescription != nil) {
            self.description = dDescription as! String
        }
        if (dMinistryName != nil) {
            self.ministryName = dMinistryName as! String
        }
        if (dImage != nil) {
            if let imageUrl = dImage?.objectForKey("secure_url") {
                self.imageUrl = imageUrl as! String
            }
            else {
                print("error: no image to display")
            }
        }
        else {
            //if image is nil
            self.image = UIImage(named: "fall-retreat-still")
        }
        if let leaderDicts = dLeaders as? [[String:AnyObject]] {
            self.leaders = leaderDicts.map{
                User(dict: $0)
            }
        }
    }
    
    func toDictionary() -> NSDictionary {
        return [
            "id": self.id,
            "name": self.ministryName,
            "description": self.description,
            "leaders": self.leaders,
            "imageUrl": self.imageUrl,
            "teamImageUrl": self.teamImageUrl
        ]
    }
}