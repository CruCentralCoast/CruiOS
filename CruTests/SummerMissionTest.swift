//
//  SummerMissionTest.swift
//  Cru
//
//  Created by Quan Tran on 3/11/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class SummerMissionTest: XCTestCase {
    let missionID = "1"
    let missionSlug = "Place"
    let missionDescription = "Description"
    let missionName = "Test Name for Testing Purposes"
    let missionURL = "www.test.com"
    let missionCost = 1000000
    let missionLeader = "Tom Stone"
    let missionStart = "2016-06-01T00:00:00.000Z"
    let missionEnd = "2016-06-11T00:00:00.000Z"
    let missionLocation = [ "country" : "Country",
        "state" : "State",
        "suburb" : "Suburb",
        "street1" : "Street"
    ]
    let missionImage = "unusedImage"
    
    let missionDict = ["_id": missionID,
        "slug": missionSlug,
        "description": missionDescription,
        "name": missionName,
        "url": missionURL,
        "cost": missionCost,
        "leaders": missionLeader,
        "startDate": missionStart,
        "endDate": missionEnd,
        "location": missionLocation,
        "imageUrl": missionImage,
        ]
    

    func testBuild() {
        let mission = SummerMission(dict: missionDict)
        
        
        XCTAssertEqual(mission.id, missionID)
        XCTAssertEqual(mission.slug, missionSlug)
        XCTAssertEqual(mission.description, missionDescription)
        XCTAssertEqual(mission.name, missionName)
        XCTAssertEqual(mission.url, missionURL)
        XCTAssertEqual(mission.cost, missionCost)
        XCTAssertEqual(mission.country, missionLocation["country"])
        XCTAssertEqual(mission.state, missionLocation["state"])
        XCTAssertEqual(mission.suburb, missionLocation["suburb"])
        XCTAssertEqual(mission.street, missionLocation["street"])
    }
    
    
}
