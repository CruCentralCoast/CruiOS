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
        if let array =  super.getObject(self.key) as? [String] {
            self.array = array
        }
    }
    
    //Adds an element to the local storage
    func addElement(elem: String) {
        self.array.append(elem)
        super.putObject(self.key, object: self.array)
    }
    
    //Get element from local storage
    func getElement(index: Int) -> String? {
        if (index > 0 && index < array.count) {
            return self.array[index]
        } else {
            return nil
        }
    }
    
    func getArray() -> [String] {
        return array
    }
    
    func replaceArray(newArray: [String]) {
        array = newArray
        super.putObject(self.key, object: self.array)
    }
    
    //Removes element from local storage
    func removeElementAtIndex(index: Int) -> String? {
        if (index > 0 && index < array.count) {
            let result = self.array.removeAtIndex(index)
            super.putObject(self.key, object: self.array)
            return result
        } else {
            return nil
        }
    }
    
    //Removes element from local storage
    func removeElement(obj: String) {
        self.array = array.filter() {$0 != obj}
        super.putObject(self.key, object: self.array)
    }
}