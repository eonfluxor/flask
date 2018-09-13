//
//  SetupTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest

var TestsCounter = 0

class SetupFlaskTests: XCTestCase {
    
    var substance:App?
    
    override func setUp() {
        super.setUp()
        
        substance = App()
        substance?.name(suffix:String(TestsCounter))
        TestsCounter = TestsCounter + 1
        XCTAssert(FluxFlaskManager.flasks.count == 0, "all flasks should dispose before this test")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.substance?.purgeArchive()
        self.substance = .none
        Flux.removeLocks()
        FluxFlaskManager.purge()
    }
    
    
}
