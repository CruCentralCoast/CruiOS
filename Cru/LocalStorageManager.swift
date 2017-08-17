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
    /// The UserDefaults to use for local storage. Change this if using a different local storage
    /// than UserDefaults.standard.
    weak private var defaults = UserDefaults.standard
    
    /// Wrapper for the UserDefaults object(forKey:) method.
    func object(forKey key: String) -> Any? {
        return self.defaults?.object(forKey: key)
    }
    
    /// Wrapper for the UserDefaults set(_:, forKey:) method.
    func set(_ value: Any?, forKey key: String) {
        self.defaults?.set(value, forKey: key)
    }
    
    /// Wrapper for the UserDefaults removeObject(forKey:) method.
    func removeObject(forKey key: String) {
        self.defaults?.removeObject(forKey: key)
    }
    
    /// Save an object to NSUserDefaults. The object must conform to the Encodable protocol.
    /// The object will be converted to a Data object, which is then stored.
    /// This method should only be used on instances of a class or struct, not on primitive types.
    /// Use putObject(_:) when storing primitive types.
    func save<T: Encodable>(_ object: T, forKey key: String) {
        let encodedObject = try! PropertyListEncoder().encode(object)
        self.defaults?.set(encodedObject, forKey: key)
    }
    
    /// Load an object from NSUserDefaults. The object must conform to the Decodable protocol.
    /// The object will be converted from a Data object, which was saved, to the inferred type.
    /// This method should only be used on instances of a class or struct, not on primitive types.
    /// Use getObject(_:) when fetching primitive types.
    func loadObject<T: Decodable>(_ key: String) -> T? {
        guard let encodedObject = self.defaults?.object(forKey: key) as? Data else {
            return nil
        }
        return try! PropertyListDecoder().decode(T.self, from: encodedObject)
    }
}
