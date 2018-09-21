//
//  SetupTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest

//intent to prevent collisions in travis when running tests in parallel
#if os(iOS)
let TARGET_NAME = "iOS"
#elseif os(tvOS)
let TARGET_NAME = "tvOS"
#elseif os(watchOS)
let TARGET_NAME = "watchOS"
#elseif os(OSX) || os(macOS)
let TARGET_NAME = "macOS"
#endif

var TestsCounter = 0

class SetupFlaskTests: XCTestCase {
    
    var substance:App?
    
    override func setUp() {
        super.setUp()
    
        substance = App()
        substance?.name(suffix:String(TestsCounter))
        substance?.name(prefix:TARGET_NAME)
        
        TestsCounter = TestsCounter + 1
        ReactorManager.purgeAll()
        XCTAssert(ReactorManager.reactors.count == 0, "all reactors should dispose before this test")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.substance?.purgeArchive()
        self.substance = .none
        Flask.removeLocks()
        ReactorManager.purgeAll()
    }
    
    
}
