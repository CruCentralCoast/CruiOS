//
//  FakeLocalStorageManager.swift
//  Cru
//
//  Created by Peter Godkin on 5/30/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class FakeLocalStorageManager: LocalStorageManager {
    
    var store = [String:Any]()
    
    override func getObject(_ key: String) -> Any? {
        return store[key]
    }
    
    override func putObject(_ key: String, object: Any) {
        store[key] = object
    }
    
    override func removeObject(_ key: String) {
        store[key] = nil
    }
}
