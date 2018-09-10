//
//  kronTests.swift
//  fluxReactor-iOSTests
//
//  Created by hassan uriostegui on 9/9/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import XCTest
import Delayed

class kronTests: XCTestCase {
    
    func testIdleWithContext() {
        
        let expectation = self.expectation(description: "execute once")
        let expectation2 = self.expectation(description: "execute ignored")
        expectation2.isInverted = true
        
        let context:Int = 90
        
        Kron.idle(1, key:"test", ctx: context){ (key,ctx) in
            expectation2.fulfill()
        }
        Kron.idle(1, key:"test", ctx: context){ (key,ctx) in
            expectation2.fulfill()
        }
        Kron.idle(1, key:"test", ctx: context){ (key,ctx) in
            expectation.fulfill()
            XCTAssert((ctx as! Int) == 90)
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
