//
//  VideoResource.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

class VideoResource: Resource {
    var description: String
    var imageURL: String
    
    required init?(dict: NSDictionary) {
        guard let description = dict["description"] as? String,
        let imageURL = dict["imageLink"] as? String else {
            return nil
        }
        self.description = description
        self.imageURL = imageURL
        
        super.init(dict: dict)
    }
}
