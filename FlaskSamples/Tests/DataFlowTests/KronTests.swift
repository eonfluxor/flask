//
//  kronTests.swift
//  flaskReactor-iOSTests
//
//  Created by hassan uriostegui on 9/9/18.
//  Copyright © 2018 Eonflux - Hassan Uriostegui. All rights reserved.
//

import XCTest
import Flask
import Delayed

class kronTests: XCTestCase {
    
    func testIdleWithContext() {
        
        let expectation = self.expectation(description: "execute once")
        let expectation2 = self.expectation(description: "execute ignored")
        expectation2.isInverted = true
        
        let context:Int = 90
        
        Kron.idle(timeOut:1, key:"test", context: context){ (key,context) in
            expectation2.fulfill()
        }
        Kron.idle(timeOut:1, key:"test", context: context){ (key,context) in
            expectation2.fulfill()
        }
        Kron.idle(timeOut:1, key:"test", context: context){ (key,context) in
            expectation.fulfill()
            XCTAssert((context as! Int) == 90)
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
