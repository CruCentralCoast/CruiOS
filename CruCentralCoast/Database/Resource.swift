//
//  Resource.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Firebase

enum ResourceType {
    case audio
    case videos
    case articles
}

class Resource: DatabaseObject {
    var author: String
    var date: Date
    
    required init?(dict: NSDictionary) {
        guard let author = dict["author"] as? String else {
            return nil
        }
        self.author = author
        guard let timeStamp = dict["date"] as? TimeStamp else {
            return nil
        }
        self.date = timeStamp.date()
    }
}
