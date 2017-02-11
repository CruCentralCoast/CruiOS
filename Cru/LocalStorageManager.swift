//
//  LocalStorageManager.swift
//  Cru
//
//  Use this local storage manager in cases where any objects must be passed.
//  For cases where objects need to be more complex extend this in a sub manager
//
//  Created by Deniz Tumer on 3/9/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class LocalStorageManager {
    let defaults: UserDefaults
    
    //initializer for the manager
    init() {
        self.defaults = UserDefaults.standard
    }
    
    //function for getting object form local storage
    func getObject(_ key: String) -> Any? {
        return defaults.object(forKey: key) as Any?
    }
    
    //function for storing an object into local storage
    func putObject(_ key: String, object: Any) {
        defaults.set(object, forKey: key)
        defaults.synchronize()
    }
    
    //function for removing an object from local storage
    func removeObject(_ key: String) {
        defaults.removeObject(forKey: key)
    }
}
