//
//  EventDetailsTest.swift
//  Cru
//
//  Created by Erica Solum on 5/25/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class EventDetailsTest: XCTestCase {

     var viewController: EventDetailsViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = NSBundle(forClass: self.dynamicType)
        let storyboard = UIStoryboard(name: "events", bundle: bundle)
        viewController = storyboard.instantiateViewControllerWithIdentifier("eventDetail") as!
       EventDetailsViewController
        
        


        
        let dic = NSDictionary(dictionary: ["_id": "563b11135e926d03001ac15c", "slug": "fall-retreat", "url":"https://www.facebook.com/events/960196250690072/", "description": "Cru Central Coast's Fall Retreat hosts 500-600 students each year! We will hear from Kurt this year down at the Ventura Beach Marriott. We will have times of hanging on the beach, listening to Kurt speak, times of intentionality in our discussion groups, and movement-specific events.", "name":"", "rideSharingEnabled": true, "__v": 2, "notificationDate":"2015-10-12T15:00:00.000Z", "parentMinistry":"563b07402930ae0300fbc09b", "parentMinistries":["563b08df2930ae0300fbc0a0","563b08fb2930ae0300fbc0a1","563b090b2930ae0300fbc0a2", "563b091f2930ae0300fbc0a3", "563b07402930ae0300fbc09b", "563b08d62930ae0300fbc09f", "563b08482930ae0300fbc09c", "563b085d2930ae0300fbc09d", "563b094e2930ae0300fbc0a5"], "imageSquare": ["public_id":"bzvuvdp24teiwrkosvua", "version":1455219064, "signature":"f9b28fd9299e7eabaef3dd9988d83ba702742d3c", "width":1268, "height":1268, "format":"jpg", "resource_type":"image", "url":"http://res.cloudinary.com/dcyhqxvmq/image/upload/v1455219064/bzvuvdp24teiwrkosvua.jpg", "secure_url":"https://res.cloudinary.com/dcyhqxvmq/image/upload/v1455219064/bzvuvdp24teiwrkosvua.jpg"], "notifications":[], "imageLink":"https://s3-us-west-1.amazonaws.com/static.crucentralcoast.com/images/events/fall-retreat.jpg", "endDate":"2015-10-18T08:00:00.000Z", "startDate":"2015-10-16T15:00:00.000Z", "location": ["postcode":"93001", "state":"CA", "suburb":"Ventura", "street1":"2055 E Harbor Blvd", "country":"United States"]])
        
        
        //Create event
        let testEvent = Event(dict: dic)
        
        viewController.event = testEvent
        _ = viewController.view
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testButtonConstraints() {
        
        //Test iPhone 4s/5/SE
        //Expected button spacing: 8
        viewController.setButtonConstraints(320)
        XCTAssertEqual(viewController.offerLeading.constant, 8.0)
        
        //Test iPhone 6
        //Expected button spacing: 26.3
        viewController.setButtonConstraints(375)
        XCTAssertEqual(viewController.offerLeading.constant, 79/3)
        
        //Test iPhone 6Plus
        //Expected button spacing: 39.33
        viewController.setButtonConstraints(414)
        XCTAssertEqual(viewController.offerLeading.constant, 118/3)
        
        //Test iPad mini/air
        //Expected button spacing:157.33
        viewController.setButtonConstraints(768)
        XCTAssertEqual(viewController.offerLeading.constant, 472/3)
        
        //Test iPad pro
        //Expected button spacing: 242.67
        viewController.setButtonConstraints(1024)
        XCTAssertEqual(viewController.offerLeading.constant, 728/3)
    }

}
