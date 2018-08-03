//
//  Person.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 7/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class Person: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var email: String!
    @objc dynamic var phone: String!
    
    // Relations
    /// Inverse relationship that is auto-updated
    let leaderCommunityGroups = LinkingObjects(fromType: CommunityGroup.self, property: "leaders")
    /// Inverse relationship that is auto-updated
    let leaderMinistryTeams = LinkingObjects(fromType: MinistryTeam.self, property: "leaders")
    let communityGroups = List<CommunityGroup>()
    let ministryTeams = List<MinistryTeam>()
    let missions = List<Mission>()
    
    func set(with dict: [String : Any]) -> Bool {
        guard let id = dict["id"] as? String,
            let nameDict = dict["name"] as? NSDictionary,
            let firstName = nameDict["first"] as? String
        else {
            assertionFailure("Client and Server data models don't agree: \(self.className())")
            return false
        }
        
        self.id = id
        self.name = firstName
        if let lastName = nameDict["last"] as? String, !lastName.isEmpty {
            self.name = "\(firstName) \(lastName)"
        }
        self.email = dict["email"] as? String
        self.phone = dict["phone"] as? String
        return true
    }
    
    func relate(with dict: [String: Any]) {
        if let communityGroupsArray = dict["communityGroups"] as? [DocumentReference] {
            DatabaseManager.instance.assignRelationList("communityGroups", on: self, with: communityGroupsArray, ofType: CommunityGroup.self)
        }
        if let ministryTeamsArray = dict["ministryTeams"] as? [DocumentReference] {
            DatabaseManager.instance.assignRelationList("ministryTeams", on: self, with: ministryTeamsArray, ofType: MinistryTeam.self)
        }
        // TODO: Uncomment when User missions are fixed on backend
//        if let missionsArray = dict["summerMissions"] as? [DocumentReference] {
//            DatabaseManager.instance.assignRelationList("missions", on: self, with: missionsArray, ofType: Mission.self)
//        }
    }
}
