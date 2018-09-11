//
//  ChainTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class ChainingTests: SetupFlaskTests {

    func testInlineMix(){
        
        let expectation = self.expectation(description: "testInlineMix")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, filling:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
      
        
        flask.mix(substance){ (substance) in
            substance.state.counter=1
            
        }.mix(substance) { (substance) in
            substance.state.counter=2
        }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,filling:substance)
        
        let object = NSObject()
        let aObject = LabRef( object )
        
        
        flask.reactor = { owner, reaction in
            
            reaction.on(AppState.named.counter, { (change) in
                
                let oldValue:Int? = change.oldValue()
                let newValue:Int? = change.newValue()
                XCTAssert(oldValue == 0)
                XCTAssert(newValue == 1)
                XCTAssert(change.key() == AppState.named.counter.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation.fulfill()
            })
            
            reaction.on(AppState.named.text, { (change) in
                
                XCTAssert(change.oldValue() == "")
                XCTAssert(change.newValue() == "reaction")
                XCTAssert(change.key() == AppState.named.text.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation2.fulfill()
            })
            
            reaction.on(AppState.named.object, { (change) in
                
                XCTAssert( isLabNil(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == AppState.named.object.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation3.fulfill()
            })
            
        }
        
        flask.mix(substance) { (substance) in
            substance.state.counter = 1
            substance.state.text = "reaction"
            substance.state.object = aObject
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, filling:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                XCTAssert(change.newValue() == 2)
            })
        }
        
        flask.mix(substance){ (substance) in
            substance.state.counter=1
        }.mix(substance) { (substance) in
            substance.state.counter=2
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
}
