//
//  ResourcesViewControllerTest.swift
//  Cru
//
//  Created by Erica Solum on 5/12/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class ResourcesViewControllerTest: XCTestCase {
    
    //Test with a fake ServerProtocol
    var serverClient: FakeServerClient!
    var viewController: ResourcesViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        let params = ["title":"Is there a god?", "type":"article", "url":"http://sketchytech.blogspot.com/2015/06/swift-and-nscoding-keeping-it-simple.html"]
        
        serverClient.postData(DBCollection.Resource, params: params, completionHandler: {error in })
        
        
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let storyboard = UIStoryboard(name: "resources", bundle: bundle)
        viewController = ResourcesViewController(serverProtocol: serverClient)
        //let ride = Ride(dict: ["time":"2016-03-05T00:08:44.000Z"])
        //viewController.ride = ride
        let resource = Resource(dict: ["title":"Is there a God?"])
        let resource2 = Resource(dict: ["title":"Prayer"])
        let resources = [resource!, resource2!]
        
        _ = viewController.view
        
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSomething() {
        XCTAssertTrue(viewController.resources.count == 0)
    }
    
    
    
 
    
}
