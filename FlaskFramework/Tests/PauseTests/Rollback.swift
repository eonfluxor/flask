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
    
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
      
        reactor
            .mix(substance){ (substance) in
                substance.prop.counter=1
            }.react()
        
        substance.captureState()
        Flask.bus.performInFluxQueue {
            XCTAssert( substance.state.counter == 1)
             substance.rollbackState()
        }
    }
}
