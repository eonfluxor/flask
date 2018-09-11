//
//  SetupTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class SetupFlaskTests: XCTestCase {
    
    var store:Store?
    
    override func setUp() {
        super.setUp()
        
        self.store = Store()
        
        Flask.releaseAllLocks()
        FlaskReactorManager.purgeOrphans()
        
        XCTAssert(FlaskReactorManager.fluxors.count == 0, "all fluxors should dispose before this test")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.store = .none
    }
    
    
}
