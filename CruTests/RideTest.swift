//
//  RideTest.swift
//  Cru
//
//  Created by Max Crane on 3/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class RideTest: XCTestCase {
    let rideDict = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "gcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2016-03-06T16:10:41.000Z", "passengers":[]]
    let rideDict2 = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "gcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2016-02-06T16:10:41.000Z", "passengers":[]]
    let rideDict3 = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "gcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2016-03-05T16:10:41.000Z", "passengers":[]]
    let rideDict4 = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "gcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2015-03-05T16:09:41.000Z", "passengers":[]]
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRideHasSeats() {
        let ride = Ride(dict: rideDict)
        XCTAssert(ride!.hasSeats())
    }
    
    func testRideNumSeatsLeft(){
        let ride = Ride(dict: rideDict)
        XCTAssertEqual(ride!.seatsLeft(), 3)
        XCTAssertEqual(ride!.seatsLeft(), "3")
    }
    
    func testHasSeats(){
        let ride = Ride(dict: rideDict)
        XCTAssertTrue(ride!.hasSeats())
        
    }
    
    func testGetCompleteAddress(){
        //let ride = Ride(dict: rideDict)
        //XCTAssertEqual(ride!.getCompleteAddress(), "1 Grand ave., SLO, CA")
    }
    
    func testRideGetTime(){
        //let ride = Ride(dict: rideDict)
        //XCTAssertEqual("4:10 PM March 6, 2016", ride!.getTime())
    }
    
    func testRideGetDriverInfo(){
        let ride = Ride(dict: rideDict)
        let rideItems = ride?.getDriverInfo()
        XCTAssertEqual(rideItems?.count, 2)
        
        for item in rideItems! {
            switch item.itemName{
            case Labels.driverName:
                XCTAssertEqual(ride?.driverName, "Joe Schmo")
            default:
                print("")
            }
        }
    }
    
    func testRideComparable(){
        let ride = Ride(dict: rideDict)   //4:10 PM March 6, 2016
        let ride2 = Ride(dict: rideDict2) //4:10 PM February 6, 2016
        let ride3 = Ride(dict: rideDict3) //4:10 PM March 5, 2016
        let ride4 = Ride(dict: rideDict4) //4:09 PM March 5, 2015
        
        XCTAssertTrue(ride > ride2)
        XCTAssertTrue(ride > ride3)
        XCTAssertTrue(ride > ride4)
        XCTAssertTrue(ride2 < ride3)
        XCTAssertTrue(ride2 > ride4)
        XCTAssertTrue(ride2 < ride)
        XCTAssertTrue(ride3 > ride4)
        XCTAssertTrue(ride3 < ride)
        XCTAssertTrue(ride3 > ride2)
        XCTAssertTrue(ride4 < ride)
        XCTAssertTrue(ride4 < ride2)
        XCTAssertTrue(ride4 < ride3)
    }
    
    func testRideEquatable(){
        let ride = Ride(dict: rideDict)
        let ride2 = Ride(dict: rideDict)
        XCTAssertTrue(ride == ride2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testShouldChangeName(){
        let view = UITextView()
        view.text = "hi"
        
        XCTAssertTrue(GlobalUtils.shouldChangeNameTextInRange(view.text,
            range: NSRange(location: 0, length: 2), text: "fshfshfshshshsf"))
        
    }

}
