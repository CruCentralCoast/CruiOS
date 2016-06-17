//
//  TestDriverRideDetail.swift
//  Cru
//
//  Created by Max Crane on 4/4/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class TestDriverRideDetail: XCTestCase {
    var viewController: RiderRideDetailViewController!
    
    override func setUp() {
        super.setUp()
        let bundle = NSBundle(forClass: self.dynamicType)
        let storyboard = UIStoryboard(name: "riderdetail", bundle: bundle)
        viewController = storyboard.instantiateViewControllerWithIdentifier("RiderRideDetailViewController") as!
        RiderRideDetailViewController
        let ride = Ride(dict: ["time":"2016-03-05T00:08:44.000Z"])
        viewController.ride = ride
        _ = viewController.view
        
    }
    
    override func tearDown() {
        super.tearDown()
    }

    
    
    func testTimeDetailok() {
       // XCTAssertEqual(viewController.date.text, "12:08 AM March 5, 2016")
    }
    
    
    func testTimeDetailbetter() {
        viewController.setTime(Ride(dict: ["time":"2016-03-05T00:09:44.000Z"])!)
       // XCTAssertEqual(viewController.date.text, "12:09 AM March 5, 2016")

    }
    
    
    func testTimeDetailbest() {
        viewController.setTime(MockTimeDetail())
       // XCTAssertEqual(viewController.date.text, "12:09 AM March 5, 2016")
        
    }

    func testPerformanceExample() {
        self.measureBlock {
        }
    }

}
