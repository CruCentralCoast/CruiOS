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
    @objc dynamic lazy var image: UIImage? = {
        UIImage.downloadedFrom(link: imageLink) { self.image = $0 }
        return nil
    }()
    
    required init?(dict: NSDictionary) {
        guard let title = dict["name"] as? String else {
            return nil
        }
        self.title = title
        
        guard let summary = dict["description"] as? String else {
            return nil
        }
        self.summary = summary
        
        guard let startDate = dict["startDate"] as? Date else {
            return nil
        }
        self.startDate = startDate
        
//        super.init()
        guard let imageLink = dict["imageLink"] as? String else {
            return nil
        }
        self.imageLink = imageLink
//        defer { UIImage.downloadedFrom(link: imageLink) { self.image = $0 } }
        
        
        self.endDate = (dict["endDate"] as? Timestamp)?.approximateDateValue()
        self.location = dict["locations"] as? String
        
        super.init()
    }
}
