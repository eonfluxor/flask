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
        let flask = Flux.flask(attachedTo:owner, binding:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
      
        
        flask.mutate(substance){ (substance) in
            substance.state.counter=1
            
        }.mutate(substance) { (substance) in
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
        let flask = Flux.flask(attachedTo:owner,binding:substance)
        
        let object = NSObject()
        let aObject = FluxRef( object )
        
        
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
                
                XCTAssert( isNilFlux(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == AppState.named.object.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation3.fulfill()
            })
            
        }
        
        flask.mutate(substance) { (substance) in
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
        let flask = Flux.flask(attachedTo:owner, binding:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                XCTAssert(substance.currentState().counter == 2)
                XCTAssert(substance.currentState().text == "mutate no override")
                
            })
        }
        
        flask.mutate(substance){ (substance) in
            substance.state.text="mutate no override"
            substance.state.counter=1
        }.mutate(substance) { (substance) in
            substance.state.counter=2
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    func testChainAbort(){
        
        let expectation = self.expectation(description: "testChain")
        expectation.isInverted = true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(attachedTo:owner, binding:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
//                XCTAssert(substance.currentState().counter == 2)
//                XCTAssert(substance.currentState().text == "mutate no override")
                
            })
        }
        
        flask.mutate(substance){ (substance) in
            substance.state.text="mutate no override"
            substance.state.counter=1
            }.mutate(substance) { (substance) in
                substance.state.counter=2
            }.abort()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
}
