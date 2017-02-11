//
//  GlobalUtilsTest.swift
//  Cru
//
//  Created by Peter Godkin on 3/12/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class GlobalUtilsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateFromString(){
        let dateStr = "2001-01-02T20:19:18.123Z"
        let date = GlobalUtils.dateFromString(dateStr)
        
        let unitFlags: NSCalendar.Unit = [.nanosecond, .second, .minute, .hour, .day, .month, .year]
        let comps = (Calendar.current as NSCalendar).components(unitFlags, from: date)
        
        XCTAssertEqual(2001, comps.year)
        XCTAssertEqual(1, comps.month)
        XCTAssertEqual(2, comps.day)
        XCTAssertEqual(20, comps.hour)
        XCTAssertEqual(19, comps.minute)
        XCTAssertEqual(18, comps.second)
        XCTAssertEqual(123, comps.nanosecond / 1000000)
    }
}
