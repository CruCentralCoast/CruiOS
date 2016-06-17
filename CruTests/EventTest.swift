//
//  EventTest.swift
//  Cru
//
//  Created by Deniz Tumer on 3/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class EventTest: XCTestCase {
    let eventDict1 = ["_id": "blah", "url": "www.whocares.com", "description": "This is a description", "name": "Event Name", "notificationDate": "2015-03-05T16:09:41.000Z", "parentMinistry": "1", "notifications": ["hello", "there"], "parentMinistries": ["min1", "min2"], "ridesharingEnabled": true, "endDate": "2015-03-05T16:09:41.000Z", "startDate": "2015-03-05T16:09:41.000Z"]

    func testEventCreation1() {
        let event = Event()!

        XCTAssertEqual(event.id, "")
    }

    func testEventCreationDict() {
        let event = Event(dict: eventDict1)!
    
        XCTAssertEqual(event.id, "blah")
        XCTAssertEqual(event.url, "www.whocares.com")
        XCTAssertEqual(event.location, NSDictionary())
    }
}
