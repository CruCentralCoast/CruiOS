//
//  EventUtilsTest.swift
//  Cru
//
//  Created by Peter Godkin on 5/16/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class EventUtilsTest: XCTestCase {
    
    var eventUtils: EventUtils!
    var serverClient: FakeServerClient!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        serverClient = FakeServerClient()
        eventUtils = EventUtils(serverProtocol: serverClient)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }


    
    func testLoadEvents() {
        
        serverClient.postData(DBCollection.Event, params: [Event.ministriesField: "Booboo"], completionHandler: {dict in })

        // Didn't writing this
        // need to be able to mock out a serverClient method that was
        // too complex to write a fake for
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
