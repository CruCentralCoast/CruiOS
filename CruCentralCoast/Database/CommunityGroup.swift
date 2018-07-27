//
//  CommunityGroup.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class CommunityGroup: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var summary: String?
    @objc dynamic private var genderString: String!
    @objc dynamic private var yearString: String!
    @objc dynamic private var weekDayString: String!
    @objc dynamic var time: String!
    @objc dynamic var imageLink: String?
    
    // Relations
    @objc dynamic var movement: Movement?
    let leaders = List<Person>()
    /// Inverse relationship that is auto-updated
    let members = LinkingObjects(fromType: Person.self, property: "communityGroups")
    
    var gender: Gender { return Gender(rawValue: self.genderString) ?? .mixed }
    var year: Year { return Year(rawValue: self.yearString) ?? .mixed }
    var weekDay: WeekDay { return WeekDay(rawValue: self.weekDayString) ?? .sunday }
    
    func set(with dict: [String : Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let genderString = dict["gender"] as? String,
            let yearString = dict["type"] as? String,
            let weekDayString = dict["dayOfWeek"] as? String,
            let time = dict["meetingTime"] as? String else { return }
        
        self.id = id
        self.name = name
        self.summary = dict["discription"] as? String
        self.genderString = genderString.lowercased()
        self.yearString = yearString.lowercased()
        self.weekDayString = weekDayString.lowercased()
        self.time = time
        self.imageLink = dict["imageLink"] as? String
    }
    
    func relate(with dict: [String : Any]) {
        if let movementReference = dict["parentMinistry"] as? DocumentReference {
            DatabaseManager.instance.assignRelation("movement", on: self, with: movementReference, ofType: Movement.self)
        }
        if let leadersArray = dict["leaders"] as? [DocumentReference] {
            DatabaseManager.instance.assignRelationList("leaders", on: self, with: leadersArray, ofType: Person.self)
        }
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
