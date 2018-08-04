//
//  VideoResource.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

class VideoResource: Resource {
    
    // Properties
    @objc dynamic var summary: String!
    @objc dynamic var imageLink: String!
    
    override func set(with dict: [String : Any]) -> Bool {
        let success = super.set(with: dict)
        
        guard let summary = dict["description"] as? String,
            let imageLink = dict["imageLink"] as? String
        else {
            assertionFailure("Client and Server data models don't agree: \(self.className())")
            return false
        }
        
        self.summary = summary
        self.imageLink = imageLink
        return success
    }
}
