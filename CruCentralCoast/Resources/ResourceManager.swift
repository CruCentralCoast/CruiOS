//
//  ResourceManager.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 7/1/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

class ResourceManager {
    
    static let instance = ResourceManager()
    
    private var retrievedResources = Set<ResourceType>()
    private var resources = [Resource]()
    
    private init() {}
    
    // This method calls the respective Database Manager method no matter what and replaces its current resources of the specified type with the new resources of that types provided by the Database Manager
    func refreshResources(ofType type: ResourceType, _ completion: @escaping ([Resource])->Void) {
        self.resources = self.resources.filter { $0.type != type }
        DatabaseManager.instance.getResources(ofType: type) { resources in
            self.resources.append(contentsOf: resources)
            completion(resources)
        }
        self.retrievedResources.insert(type)
    }
    
    // This method only calls the respective Database Manager method if it has not already downloaded the resources of the specified type
    func getResources(ofType type: ResourceType, _ completion: @escaping ([Resource])->Void) {
        if retrievedResources.contains(type) {
            completion(self.resources.filter { $0.type == type })
        } else {
            DatabaseManager.instance.getResources(ofType: type) { resources in
                self.resources.append(contentsOf: resources)
                completion(resources)
            }
        }
        self.retrievedResources.insert(type)
    }
}
