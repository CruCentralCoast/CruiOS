//
//  CommunityGroup.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import RealmSwift

class CommunityGroup: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var summary: String?
    @objc dynamic var gender: String!
    @objc dynamic var year: String!
    @objc dynamic var weekDay: String!
    @objc dynamic var time: String!
    @objc dynamic var imageLink: String?
    
    // Relations
    @objc dynamic var movement: Movement?
    let leaders = List<Person>()
    /// Inverse relationship that is auto-updated
    let members = LinkingObjects(fromType: Person.self, property: "communityGroups")
    
    func set(with dict: [String : Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let gender = dict["gender"] as? String,
            let year = dict["type"] as? String,
            let weekDay = dict["dayOfWeek"] as? String,
            let time = dict["meetingTime"] as? String else { return }
        
        self.id = id
        self.name = name
        self.summary = dict["discription"] as? String
        self.gender = gender
        self.year = year
        self.weekDay = weekDay
        self.time = time
        self.imageLink = dict["imageLink"] as? String
    }
    
    func relate(with dict: [String : Any]) {
        // TODO
    }
}

enum Gender: String {
    case male = "male"
    case female = "female"
    case mixed = "other"
}

enum Year: String {
    case freshman = "freshmen"
    case sophomore = "sophomore"
    case junior = "junior"
    case senior = "senior"
    case seniorPlus = "seniorplus"
    case mixed = "mixed ages"
}

enum WeekDay: String {
    case sunday = "sunday"
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
}
