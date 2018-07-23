//
//  Event.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import Firebase

class Event: NSObject, DatabaseObject {
    var title: String
    var startDate: Date
    var endDate: Date?
    var summary: String
    var location: String?
    var imageLink: String
    @objc dynamic var image: UIImage?
    
    required init?(dict: NSDictionary) {
        guard let title = dict["name"] as? String,
        let summary = dict["description"] as? String,
        let startDate = dict["startDate"] as? Date,
        let imageLink = dict["imageLink"] as? String
        else {
            return nil
        }
        self.title = title
        self.summary = summary
        self.startDate = startDate
        self.imageLink = imageLink
        //self.endDate = (dict["endDate"] as? Timestamp)?.approximateDateValue()
        self.location = dict["locations"] as? String
        
        super.init()
    }
}
