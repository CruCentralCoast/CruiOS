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
    
    override func object(forKey key: String) -> Any? {
        return store[key]
    }
    
    override func set(_ value: Any?, forKey key: String) {
        store[key] = value
    }
    
    override func removeObject(forKey key: String) {
        store[key] = nil
    }
}
