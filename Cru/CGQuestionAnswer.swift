//
//  CGQuestionAnswer.swift
//  Cru
//
//  Created by Peter Godkin on 5/25/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class CGQuestionAnswer {
    
    let question: String
    let value: String
    
    init(question: String, value: String) {
        self.question = question
        self.value = value
    }
    
    func getDict() -> [String:String] {
        return ["question":question, "value":value]
    }
    
}