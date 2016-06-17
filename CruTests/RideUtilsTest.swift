//
//  RideUtilsTest.swift
//  Cru
//
//  Created by Max Crane on 3/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class RideUtilsTest: XCTestCase {
    
    var serverClient: FakeServerClient!
    var rideUtils: RideUtils!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        serverClient = FakeServerClient()
        rideUtils = RideUtils(serverProtocol: serverClient)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPostAndRemoveRideOffer() {
        //test post
        var readyExpectation = self.expectationWithDescription("post a ride")
        var postedRide: Ride!
        
        rideUtils.postRideOffer("some-event-id", name: "Joe Schmo", phone: "1234567890", seats: 5, time: "2017-05-26T10:47:00.000Z", location: ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."], radius: 3, direction: "both", handler :{ result in
            XCTAssert(result != nil)
            postedRide = result!
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "Error")
        }
        
        
        XCTAssert("some-event-id" == postedRide.eventId)
        XCTAssert("Joe Schmo" == postedRide.driverName)
        XCTAssert("1234567890" == postedRide.driverNumber)
        XCTAssert(5 == postedRide.seats)
        XCTAssert(3 == postedRide.radius)
        XCTAssert("both" == postedRide.direction)

        //test drop
        readyExpectation = self.expectationWithDescription("drop a ride")

        rideUtils.leaveRideDriver(postedRide.id, handler: { success in
            XCTAssert(success)
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "Error")
        }
    }
    
    func testPatch() {
        var readyExpectation = self.expectationWithDescription("post a ride")
        var id: String!
        
        rideUtils.postRideOffer("test-event-id", name: "Joe Schmo", phone: "1234567890", seats: 5, time: "2017-05-26T10:47:00.000Z", location: ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."], radius: 3, direction: "both", handler :{ result in
            XCTAssert(result != nil)
            id = result?.id
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "Error")
        }
        
        
        readyExpectation = self.expectationWithDescription("patch a ride")
        
        rideUtils.patchRide(id, params: ["seats": 17], handler :{ result in
            XCTAssert(result != nil)
            XCTAssert(result?.seats == 17)
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "Error")
        }
    }
    
    func testAddAndDropPassenger(){
        /*var rideId: String?
        var passId: String?
        
        //posts a ride
        var readyExpectation = self.expectationWithDescription("post a ride")
        rideUtils.postRideOffer("563b11135e926d03001ac15c", name: "Joe Schmo", phone: "1234567890", seats: 5, location: ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."], radius: 3, direction: "both", handler :{ success in
            XCTAssert(success)
            readyExpectation.fulfill()
            },
            idhandler: { id in
                rideId = id
        })
        waitForExpectationsWithTimeout(5) {error in
            XCTAssertNil(error, "Error")
        }
        
        //add passenger
        readyExpectation = self.expectationWithDescription("join a ride")
        rideUtils.joinRide("Test Tester", phone: "1234567890", direction: "to",  rideId: rideId!, handler: { obj in
                readyExpectation.fulfill()
            })
        waitForExpectationsWithTimeout(5) {error in
            XCTAssertNil(error, "Error")
        }
        
        //drop passenger
        readyExpectation = self.expectationWithDescription("leave a ride")
        rideUtils.leaveRidePassenger(passId!, rideid: rideId!, handler: { success in
            print("here 3")
            XCTAssert(success)
            readyExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(5) {error in
            XCTAssertNil(error, "Error")
        }
        
        
        //removes the ride
        readyExpectation = self.expectationWithDescription("drop a ride")
        
        XCTAssertNotNil(rideId)
        
        rideUtils.leaveRideDriver(rideId!, handler: { success in
            XCTAssert(success)
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) {error in
            XCTAssertNil(error, "Error")
        }*/
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
