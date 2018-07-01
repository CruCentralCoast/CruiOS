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
    
    func refreshResources(ofType type: ResourceType, _ completion: @escaping ([Resource])->Void) {
        self.resources = self.resources.filter { $0.type != type }
        DatabaseManager.instance.getResources(ofType: type) { resources in
            self.resources.append(contentsOf: resources)
            completion(resources)
        }
        self.retrievedResources.insert(type)
    }
    
    func getResources(ofType type: ResourceType, _ completion: @escaping ([Resource])->Void) {
        if retrievedResources.contains(type) {
            completion(self.resources.filter { $0.type == type })
        }
        else {
            DatabaseManager.instance.getResources(ofType: type) { resources in
                self.resources.append(contentsOf: resources)
                completion(resources)
            }
        }
        self.retrievedResources.insert(type)
    }
}
