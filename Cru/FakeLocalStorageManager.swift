//
//  FakeLocalStorageManager.swift
//  Cru
//
//  Created by Peter Godkin on 5/30/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class FakeLocalStorageManager: LocalStorageManager {
    
    var store = [String:AnyObject]()
    
    override func getObject(key: String) -> AnyObject? {
        return store[key]
    }
    
    override func putObject(key: String, object: AnyObject) {
        store[key] = object
    }
    
    override func removeObject(key: String) {
        store[key] = nil
    }
}