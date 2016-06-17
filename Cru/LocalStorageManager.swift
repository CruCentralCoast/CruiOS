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
    let defaults: NSUserDefaults
    
    //initializer for the manager
    init() {
        self.defaults = NSUserDefaults.standardUserDefaults()
    }
    
    //function for getting object form local storage
    func getObject(key: String) -> AnyObject? {
        return defaults.objectForKey(key)
    }
    
    //function for storing an object into local storage
    func putObject(key: String, object: AnyObject) {
        defaults.setObject(object, forKey: key)
        defaults.synchronize()
    }
    
    //function for removing an object from local storage
    func removeObject(key: String) {
        defaults.removeObjectForKey(key)
    }
}