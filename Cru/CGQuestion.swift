//
//  CGQuestion.swift
//  Cru
//
//  Created by Peter Godkin on 5/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

enum CGQuestionType : String {
    
    case TEXT = "text"
    case SELECT = "select"
    
    func name()->String {
        return self.rawValue
    }
}

class CGQuestion {
    
    static let ministryField = "ministry"

    let id: String
    let ministry: String
    let question: String
    let type: CGQuestionType
    let options: [String]
    let required: Bool

    init(dict: NSDictionary) {
        id = dict["_id"] as! String
        ministry = CGQuestion.getString(dict, key: CGQuestion.ministryField)
        question = CGQuestion.getString(dict, key: "question")
        type = CGQuestionType(rawValue: dict["type"] as! String)!
        required = dict["required"] as! Bool
        let optionStructs = dict["selectOptions"] as! [NSDictionary]
        
        
        options = optionStructs.map() {$0["value"] as! String}
    }
    
    static
        func getString(dict: NSDictionary, key: String) -> String {
        if let value = dict[key] as? String {
            return value
        } else {
            return ""
        }
    }
}