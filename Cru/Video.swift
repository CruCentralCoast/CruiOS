//
//  Video.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Video {
    let title: String
    let url: NSURL
    
    required init(title: String, url: NSURL) {
        self.title = title
        self.url = url
    }
    
    
}