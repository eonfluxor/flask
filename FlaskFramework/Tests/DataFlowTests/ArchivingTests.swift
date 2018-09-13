//
//  archiveTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class archiveTests: SetupFlaskTests {
    
    func testarchive(){
        
        let expectation = self.expectation(description: "archive value")
        let expectationUnarchive = self.expectation(description: "value must persist")
        
        let expectedValue = Int(Date().timeIntervalSince1970)
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner, mixing:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flask.mix(substance){ (substance) in
            substance.state.counter=expectedValue
        }.react()
        
        wait(for: [expectation], timeout: 2)
        
        flask.unbind()
        
        let substanceName = substance.name()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            let anotherSubstance = App(name:substanceName)
            
            XCTAssert(anotherSubstance.state.counter == expectedValue)
            
            expectationUnarchive.fulfill()
        }
        
        wait(for: [expectationUnarchive], timeout: 5)
        
    }
}
