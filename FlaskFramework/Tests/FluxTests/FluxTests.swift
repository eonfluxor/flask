//
//  FlaskTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class FlaskTests: SetupFlaskTests {
    

    func testCallback(){
        
        let expectation = self.expectation(description: "testCallback Mix counter")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,filling:substance)
        
        flask.reactor = { owner, reaction in
            
            reaction.on( AppState.named.counter, { (change) in
                expectation.fulfill()
            })
            
        }
        
        DispatchQueue.main.async {
            Lab.applyMixer(AppMixers.Count, payload: ["test":"callback"])
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    func testOwner(){
        
        let expectation = self.expectation(description: "testOwner Delegate")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,filling:substance)
        
        flask.reactor = { owner, reaction in
            
            reaction.at(substance)?.on(AppState.named.counter, { (change) in
                owner.reactionMethod(expectation)
            })
            
        }
        
        DispatchQueue.main.async {
            Lab.applyMixer(AppMixers.Count, payload: ["test":"testOwner"])
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testEmpty(){
        
        let expectation = self.expectation(description: "testEmpty")
        expectation.isInverted=true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,filling:substance)
        
        flask.reactor={owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flask.empty()
        Lab.applyMixer(AppMixers.Count, payload: ["test":"empty"])
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    func testStrongOwner(){
        
        let expectation = self.expectation(description: "testStrongOwner")
        
        let substance = self.substance!
        let owner:TestOwner? = TestOwner()
        
        weak var flask = Lab.flask(ownedBy:owner!, filling:substance)
        
        flask?.reactor = { owner, reaction in}
   
        
        DispatchQueue.main.async {
            
            if flask != nil {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testOwnerDispose(){
        
        let expectation = self.expectation(description: "testOwnerDispose")
        
        let substance = self.substance!
        var weakOwner:TestOwner? = TestOwner()
        
        weak var flask = Lab.flask(ownedBy:weakOwner!, filling:substance)
        
        flask?.reactor = { owner, reaction in}
        
        
        // Calling formulate after disposing the owner
        // should cause the factory to release this flask
        weakOwner = nil
        
        Lab.applyMixer(AppMixers.Count, payload:  ["test":"ownerDispose"])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  {
            if flask == nil {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    func testChange(){
        
        let expectation = self.expectation(description: "testChange Mix")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,filling:substance)
        
        flask.reactor = { owner, reaction in
            
            reaction.on(AppState.named.counter, { (change) in
                
                XCTAssert(change.oldValue() == 0)
                XCTAssert(change.newValue() == 1)
                XCTAssert(change.key() == AppState.named.counter.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation.fulfill()
            })
            
        }
        
        Lab.applyMixer(AppMixers.Count, payload: ["test":"change"])
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    
    func testGlobalApp(){
        
        let expectation = self.expectation(description: "testGlobalSubstance testInlineMix")
        
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, filling:Substances.app)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                XCTAssert(Substances.app.state.counter == 2)
            })
        }
        
        flask.mix(Substances.app,{ (substance) in
            substance.state.counter=1
        }).mix(Substances.app) { (substance) in
            substance.state.counter=2
            }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testStateInternal(){
        
        let expectation = self.expectation(description: "testStateInternal")
        expectation.isInverted = true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, filling:substance)
        
        flask.reactor = { owner, reaction in
            reaction.on("_internal", { (change) in
                expectation.fulfill()
            })
        }
        
        flask.mix(substance){ (substance) in
            substance.state._internal="shouldn't cause mix"
        }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    
    
    
}
