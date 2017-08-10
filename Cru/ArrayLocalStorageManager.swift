//
//  ArrayLocalStorageManager.swift
//  Cru
//
//  Created by Peter Godkin on 4/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class ArrayLocalStorageManager: LocalStorageManager {
    var key: String = ""
    var array: [String] = []
    
    //initializer with key
    init(key: String) {
        super.init()
        
        self.key = key
        if let array =  super.object(forKey: self.key) as? [String] {
            self.array = array
        }
    }
    
    //Adds an element to the local storage
    func addElement(_ elem: String) {
        self.array.append(elem)
        super.set(self.array, forKey: self.key)
    }
    
    //Get element from local storage
    func getElement(_ index: Int) -> String? {
        if (index > 0 && index < array.count) {
            return self.array[index]
        } else {
            return nil
        }
    }
    
    func getArray() -> [String] {
        return array
    }
    
    func replaceArray(_ newArray: [String]) {
        array = newArray
        super.set(self.array, forKey: self.key)
    }
    
    //Removes element from local storage
    func removeElementAtIndex(_ index: Int) -> String? {
        if (index > 0 && index < array.count) {
            let result = self.array.remove(at: index)
            super.set(self.array, forKey: self.key)
            return result
        } else {
            return nil
        }
    }
    
    //Removes element from local storage
    func removeElement(_ obj: String) {
        self.array = array.filter() {$0 != obj}
        super.set(self.array, forKey: self.key)
    }
}
