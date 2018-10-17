//
//  Rollback.swift
//  Flask-iOS
//
//  Created by hassan uriostegui on 10/16/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import XCTest

class Rollback: SetupFlaskTests {
    
    func testRollback(){
    
        let expectation = self.expectation(description: "before rollback 1")
        let expectation2 = self.expectation(description: "after rollback zero")
        
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
      
        substance.captureState()
        
        reactor
            .mix(substance){ (substance) in
                substance.prop.counter=1
            }.react()
        
       
        Flask.bus.performInFluxQueue {
            XCTAssert(substance.state.counter == 1)
            expectation.fulfill()
            substance.rollbackState(){
                XCTAssert(substance.state.counter == 0)
                expectation2.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
