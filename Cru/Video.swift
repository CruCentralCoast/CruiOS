//
//  Video.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Video {
    // MARK: Properties
    var title: String!
    var author: String!
    var id: String!
    var url: String!
    var date: Date!
    var tags: [String]!
    var restricted: Bool!
    var abstract: String!
    var videoURL: String!
    var thumbnailURL: String!
    
    init?() {
        self.title = ""
        self.id = ""
        self.author = ""
        self.id = ""
        self.url = ""
        self.date = nil
        self.tags = []
        self.restricted = false
        self.abstract = ""
        self.videoURL = ""
        self.thumbnailURL = ""
    }
    
    init?(id: String?, title: String?, url: String?, date: Date?, tags: [String]?, abstract: String?, videoURL: String?, thumbnailURL: String?, restricted: Bool!) {
        // Initialize properties
        self.id = id
        self.title = title
        self.url = url
        self.date = date
        self.tags = tags
        self.abstract = abstract
        self.videoURL = videoURL
        self.restricted = restricted
        self.thumbnailURL = thumbnailURL
    }
    
    
}
