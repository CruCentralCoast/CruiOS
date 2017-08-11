//
//  ArrayLocalStorageManager.swift
//  Cru
//
//  This array llocal storage manager is used for storing array objects
//  in local storage on the phone
//
//  Created by Deniz Tumer on 3/9/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class MapLocalStorageManager<C: Codable>: LocalStorageManager {
    var key: String = ""
    private var map: [String: C] = [:]
    
    /// An array containing just the keys of the dictionary.
    var keys: [String] {
        return Array(self.map.keys)
    }
    
    /// Initialize with the key of a dictionary that is or will be stored locally on device.
    init(key: String) {
        super.init()
        
        self.key = key
        self.loadMap()
    }
    
    /// Load the dictionary from storage if it exists.
    private func loadMap() {
        let map: [String: C]? = super.loadObject(self.key)
        if let map = map {
            self.map = map
        }
    }
    
    /// Store the object in the dictionary, and then save the dictionary.
    override func save<T: Codable>(_ object: T, forKey key: String) {
        self.map[key] = object as? C
        super.save(self.map, forKey: self.key)
    }
    
    /// Get an object stored in the dictionary.
    override func object(forKey key: String) -> Any? {
        return self.map[key]
    }
    
    /// Remove element from the dictionary and from local storage.
    func removeElement(_ key: String) {
        if let _ = self.map[key] {
            self.map.removeValue(forKey: key)
            super.save(self.map, forKey: self.key)
        }
        
        //if there are no objects in the map remove the whole object
        if map.count == 0 {
            super.removeObject(forKey: key)
        }
    }
    
    /// Delete the entire dictionary from local storage.
    func deleteMap(_ key: String) {
        super.removeObject(forKey: key)
    }
}
