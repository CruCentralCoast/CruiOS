//
//  Resource.swift
//  Cru
//  Represents a resource, such as an article, video, or audio file in the Cru database.
//
//  Created by Erica Solum on 2/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

public enum ResourceType: String{
    case Article = "article"
    case Audio = "audio"
    case Video = "video"
}

class Resource {
    // MARK: Properties
    var title: String!
    var author: String!
    var id: String!
    var url: String!
    var type: ResourceType!
    var date: Date!
    var tags: [String]!
    var restricted: Bool!
    var description: String!
    
    init?() {
        self.title = ""
        self.id = ""
        self.author = ""
        self.id = ""
        self.url = ""
        self.type = nil
        self.date = nil
        self.tags = []
        self.restricted = false
        self.description = ""
    }
    
    init?(id: String?, title: String?, url: String?, type: ResourceType?, date: String?, tags: [String]?, description: String?) {
        // Initialize properties
        self.id = id
        self.title = title
        self.url = url
        self.type = type
        if let date = date {
            self.date = GlobalUtils.dateFromString(date)
        }
        self.tags = tags
        self.description = description
    }
    
    convenience init?(dict : NSDictionary) {
        self.init()
        if let id = dict["_id"]  {
            self.id = id as? String
        }
        
        if let title = dict["title"]  {
            self.title = title as? String
        }
        
        if let type = dict["type"] as? String{
            self.type = ResourceType(rawValue: type)
        }
        
        if let url = dict["url"]  {
            self.url = url as? String
        }
        
        if let date = dict["date"] as? String {
            self.date = GlobalUtils.dateFromString(date)
        }
        
        if let tags = dict["tags"]  {
            
            self.tags = tags as? [String]
        }
        
        if let dAuthor = dict["author"] {
            self.author = dAuthor as! String
        }
        
        if let access = dict["restricted"] {
            self.restricted = access as! Bool
        }
        
        if let desc = dict["description"] {
            self.description = desc as! String
        }
        
        //self.init(id: id, title: title, url: url, type: type, date: date, tags: tags)
    }
}
