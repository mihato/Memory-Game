//
//  URLComponentsTests.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import XCTest
@testable import Memory_Game

class URLComponentsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPhotosRequestBuilder() {
        let request = GetPhotosListRequest(feature: .popular)
        let builder = URLComponents(request: request, authKey: "test_key")
        XCTAssertNotNil(builder)
        XCTAssertNotNil(builder?.url)
        if let url = builder?.url?.absoluteString {
            XCTAssert(url.contains("consumer_key=test_key"))
            XCTAssert(url.contains("feature=popular"))
            XCTAssert(url.contains("sort_direction=desc"))
            XCTAssert(url.contains("page=1"))
            XCTAssert(url.contains("rpp=20"))
        }
    }
    
    func testPhotosSearchRequestBuilder() {
        let request = PhotosSearchRequest(searchPattern: "cat")
        let builder = URLComponents(request: request, authKey: "test_key")
        XCTAssertNotNil(builder)
        XCTAssertNotNil(builder?.url)
        if let url = builder?.url?.absoluteString {
            XCTAssert(url.contains("consumer_key=test_key"))
            XCTAssert(url.contains("term=cat"))
            XCTAssert(url.contains("sort_direction=desc"))
            XCTAssert(url.contains("page=1"))
            XCTAssert(url.contains("rpp=50"))
        }
    }
    
}
