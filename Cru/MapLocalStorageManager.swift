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

class MapLocalStorageManager: LocalStorageManager {
    var key: String = ""
    var map: [String: Any] = [:]
    
    //initializer with key
    init(key: String) {
        super.init()
        
        self.key = key
        if let map =  super.getObject(self.key) as? [String: AnyObject] {
            self.map = map
        }
    }
    
    //Adds an element to the local storage
    //NOTE: FOR NOW SETTING VALUE PAIRS TO BOOLEANS
    func addElement(_ key: String, elem: Any) {
        let obj = self.map[key]
        
        if obj == nil {
            self.map[key] = elem
        }
        
        super.putObject(self.key, object: self.map)
    }
    
    //Get element from local storage
    func getElement(_ key: String) -> Any? {
        return self.map[key]
    }
    
    //Removes element from local storage
    func removeElement(_ key: String) {
        if let _ = self.map[key] {
            self.map.removeValue(forKey: key)
            super.putObject(self.key, object: self.map)
        }
        
        //if there are no objects in the map remove the whole object
        if map.count == 0 {
            super.removeObject(key)
        }
    }
    
    //deletes the entire map
    func deleteMap(_ key: String) {
        super.removeObject(key)
    }
    
    //gets the keys as an array
    func getKeys() -> [String] {
        return Array(map.keys)
    }
}
