//
//  ArticleResource.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

class ArticleResource: Resource {
    var description: String
    
    required init?(dict: NSDictionary) {
        guard let description = dict["description"] as? String else {
            return nil
        }
        self.description = description
        
        super.init(dict: dict)
    }
}
