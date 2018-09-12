//
//  SetupTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class SetupFlaskTests: XCTestCase {
    
    var store:App?
    
    override func setUp() {
        super.setUp()
        
        store = App()
        store?.name(suffix:String(Date().timeIntervalSince1970))
        XCTAssert(FluxFlaskManager.flasks.count == 0, "all flasks should dispose before this test")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.store?.purgeArchive()
        self.store = .none
        Flux.removeLocks()
        FluxFlaskManager.purge()
    }
    
    
}
