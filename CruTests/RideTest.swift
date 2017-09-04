//
//  RideTest.swift
//  Cru
//
//  Created by Max Crane on 3/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class RideTest: XCTestCase {
    let rideDict = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "fcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2016-03-06T16:10:41.000Z", "passengers":[]] as [String : Any]
    let rideDict2 = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "fcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2016-02-06T16:10:41.000Z", "passengers":[]] as [String : Any]
    let rideDict3 = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "fcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2016-03-05T16:10:41.000Z", "passengers":[]] as [String : Any]
    let rideDict4 = ["location": ["postcode":"93401", "state":"CA", "suburb":"SLO", "street1":"1 Grand ave."],"_id": "blah", "direction": "both", "seats": 3, "radius": 2, "fcm_id": "blah", "driverNumber": "1234567890", "driverName": "Joe Schmo", "event": "replacethis", "time": "2015-03-05T16:09:41.000Z", "passengers":[]] as [String : Any]
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRideHasSeats() {
        let ride = Ride(dict: rideDict as NSDictionary)
        XCTAssert(ride!.hasSeats())
    }
    
    func testRideNumSeatsLeft(){
        let ride = Ride(dict: rideDict as NSDictionary)
        XCTAssertEqual(ride!.seatsLeft(), 3)
        XCTAssertEqual(ride!.seatsLeft(), "3")
    }
    
    func testHasSeats(){
        let ride = Ride(dict: rideDict as NSDictionary)
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
        let ride = Ride(dict: rideDict as NSDictionary)
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
        let ride = Ride(dict: rideDict as NSDictionary)   //4:10 PM March 6, 2016
        let ride2 = Ride(dict: rideDict2 as NSDictionary) //4:10 PM February 6, 2016
        let ride3 = Ride(dict: rideDict3 as NSDictionary) //4:10 PM March 5, 2016
        let ride4 = Ride(dict: rideDict4 as NSDictionary) //4:09 PM March 5, 2015
        
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
        let ride = Ride(dict: rideDict as NSDictionary)
        let ride2 = Ride(dict: rideDict as NSDictionary)
        XCTAssertTrue(ride == ride2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
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
