//
//  Article.swift
//  Cru
//
//  Created by Erica Solum on 4/26/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Article {
    let title: String
    let url: URL
    let content: String
    
    required init(title: String, url: URL, content: String) {
        self.title = title
        self.url = url
        self.content = content
    }
    
    
}
