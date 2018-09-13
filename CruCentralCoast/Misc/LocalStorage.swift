//
//  LocalStorage.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/1/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

struct LocalStorage {
    
    static let preferences = UserDefaultsStorage()
    static let documents = DocumentsStorage()
    static let secure = KeychainStorage()

    private init() {}
}

class UserDefaultsStorage {
    
    enum UserDefaultsKey: String {
        case subscribedMovements = "SubscribedMovements"
    }
    
    fileprivate init() {}
    
    func set(_ value: Any?, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func getObject(forKey key: UserDefaultsKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
}

class DocumentsStorage {
    fileprivate init() {}
}

class KeychainStorage {
    fileprivate init() {}
}
