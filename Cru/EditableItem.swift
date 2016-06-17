//
//  EditableItem.swift
//  Cru
//
//  Created by Max Crane on 5/4/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class EditableItem {
    var itemName: String!
    var itemValue:String!
    var itemEditable:Bool!
    var itemIsText:Bool!
    var desiredValue:AnyObject?
    var wasChanged = false
    
    init(itemName: String, itemValue: String, itemEditable: Bool, itemIsText: Bool){
        self.itemName = itemName
        self.itemValue = itemValue
        self.itemEditable = itemEditable
        self.itemIsText = itemIsText
    }
    
    
}