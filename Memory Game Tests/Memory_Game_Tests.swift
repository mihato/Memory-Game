//
//  Memory_Game_Tests.swift
//  Memory Game Tests
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import XCTest
@testable import Memory_Game

class Memory_Game_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Dispatcher.dispatchOperationBuilder = MockDispatchOperationsBuilder()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPhotosLoading() {
        let semaphore = DispatchSemaphore(value: 0)
        var request = PhotosSearchRequest(searchPattern: "cat")
        request.onError = { error in
            XCTAssert(false)
            semaphore.signal()
        }
        request.onSuccess = { data in
            XCTAssertFalse(data.isEmpty)
            XCTAssertNotNil(data["photos"])
            XCTAssert(data["photos"] is [[String: Any]])
            if let photos = data["photos"] as? [[String: Any]] {
                XCTAssert(photos.count > 0)
                if let photoData = photos.first {
                    let photo = Photo(data: photoData)
                    XCTAssertNotNil(photo)
                }
            }
            semaphore.signal()
        }
        Dispatcher.default.perform(request: request)
        semaphore.wait()
    }
    
    func testGame() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "testimage", ofType: "png"),
            let image = UIImage(contentsOfFile: path) else {
                XCTFail("no test image")
                return
        }
        let game = Game(images: [image])
        XCTAssertTrue(game.images.count == 2)
        game.start()
        XCTAssertTrue(game.testTurn((firstTry: 0, secondTry: nil)))
        XCTAssertTrue(game.testTurn((firstTry: 0, secondTry: 1)))
        XCTAssertTrue(game.turnsCount == 1)
        XCTAssertTrue(game.isImageFlipped(at: 0))
        game.stop()
        XCTAssertFalse(game.testTurn((firstTry: 0, secondTry: nil)))
    }
    
}
