//
//  ResourceTag.swift
//  Cru
//
//  Created by Erica Solum on 9/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class ResourceTag {
    //MARK: Properties
    var id: String!
    var title: String!
    var resources: [String]!
    var selected: Bool!
    
    init?() {
        self.id = ""
        self.title = ""
        self.selected = true
    }
    
    init?(id: String?, title: String?) {
        self.id = id
        self.title = title
        self.selected = true
    }
    
    convenience init?(dict : NSDictionary) {
        self.init()
        if let id = dict["_id"]  {
            self.id = id as? String
        }
        
        if let title = dict["title"]  {
            self.title = title as? String
        }
        
        if let resources = dict["resources"] {
            self.resources = resources as? [String]
        }
        self.selected = true
    }
}
