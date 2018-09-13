//
//  ChainTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class ChainingTests: SetupFlaskTests {

    func testInlineMutation(){
        
        let expectation = self.expectation(description: "testInlineMutation")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner, mixing:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
      
        
        flask
            .mix(substance){ (substance) in
                substance.stateMix.counter=1
            }.mix(substance) { (substance) in
                substance.stateMix.counter=2
            }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner,mixing:substance)
        
        let object = NSObject()
        let aObject = FlaskNSRef( object )
        
        
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
                
                XCTAssert( isNilorNull(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == AppState.named.object.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation3.fulfill()
            })
            
        }
        
        flask.mix(substance) { (substance) in
            substance.stateMix.counter = 1
            substance.stateMix.text = "reaction"
            substance.stateMix.object = aObject
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        let expectation2 = self.expectation(description: "testChain")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner, mixing:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                
                XCTAssert(substance.state.counter == 2)
                expectation.fulfill()
            })
            
            reaction.on(AppState.named.text, { (change) in
                
                XCTAssert(substance.state.text == "mix no override")
                expectation2.fulfill()
            })
        }
        
        flask
            .mix(substance){ (substance) in
                substance.stateMix.counter=2
            }.mix(substance) { (substance) in
                substance.stateMix.text="mix no override"
            }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    func testChainAbort(){
        
        let expectation = self.expectation(description: "testChain")
        expectation.isInverted = true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner, mixing:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
//                XCTAssert(substance.state.counter == 2)
//                XCTAssert(substance.state.text == "mix no override")
                
            })
        }
        
        flask
            .mix(substance){ (substance) in
                substance.stateMix.text="mix no override"
                substance.stateMix.counter=1
            }.mix(substance) { (substance) in
                substance.stateMix.counter=2
            }.abort()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
}
