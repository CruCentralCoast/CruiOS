//
//  ResourceTest.swift
//  Cru
//
//  Created by Erica Solum on 3/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import XCTest

class ResourceTest: XCTestCase {
    let resourceDict1 = ["_id": "56d79458e73872030083a915",
        "slug": "of-all-the-religions-why-should-i-choose-christianity",
        "title": "Of All the Religions, Why Should I Choose Christianity?",
        "type": "video",
        "url": "http://www.everystudent.com/videos/tim2.html",
        "_v": 0,
        "date": "2016-03-02T00:00:00.000Z",
        "tags": [
            "56d79219e73872030083a90e"
        ]] as [String : Any]
    
    let resourceDict2 = ["_id": "56d793afe73872030083a913",
        "slug": "is-there-a-god",
        "title": "Is There a God?",
        "type": "article",
        "url": "http://www.everystudent.com/features/isthere.html",
        "__v": 0,
        "date": "2016-03-01T00:00:00.000Z",
        "author": "Marilyn Adamson",
        "restricted": false,
        "tags": [
            "56d79219e73872030083a90e"
        ]] as [String : Any]
    let resourceDict3 = ["_id": "56a8689d2a55a7030050f23e",
        "slug": "the-purpose-of-prayer",
        "title": "The Purpose of Prayer",
        "type": "article",
        "url": "http://www.cru.org/train-and-grow/10-basic-steps/4-prayer.html",
        "__v": 1,
        "date": "2016-01-24T00:00:00.000Z",
        "author": "Bill Bright",
        "restricted": true,
        "tags": [
            "56a868b72a55a7030050f23f"
        ]] as [String : Any]
    
    
    //Testing creating a resource with optional data fields like author and restricted
    func testResourceCreationDict() {
        let res1 = Resource(dict: resourceDict1 as NSDictionary)!
        let res2 = Resource(dict: resourceDict2 as NSDictionary)!
        let res3 = Resource(dict: resourceDict3 as NSDictionary)!
        
        XCTAssertEqual(res1.author, "")
        XCTAssertEqual(res1.restricted, false)
        
        XCTAssertEqual(res2.author, "Marilyn Adamson")
        XCTAssertEqual(res2.restricted, false)
        
        XCTAssertEqual(res3.author, "Bill Bright")
        XCTAssertEqual(res3.restricted, true)
        
        
        
    }
}
