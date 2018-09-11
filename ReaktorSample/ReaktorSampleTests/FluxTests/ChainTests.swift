//
//  ChainTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflux. All rights reserved.
//

import XCTest
import Reaktor_iOS

class ChainingTests: SetupFluxTests {

    func testInlineMutation(){
        
        let expectation = self.expectation(description: "testInlineMutation")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner, binding:store)
        
        flux.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flux.mutate(store,{ (store, commit, abort) in
            store.state.counter=1
            commit()
        }).mutate(store) { (store, commit, abort) in
            store.state.counter=2
            commit()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        let object = NSObject()
        let aObject = FluxRef( object )
        
        
        flux.reactor = { owner, reaction in
            
            reaction.on(State.prop.counter, { (change) in
                
                XCTAssert(change.oldValue() == 0)
                XCTAssert(change.newValue() == 1)
                XCTAssert(change.key() == State.prop.counter.rawValue)
                XCTAssert(change.store() === store)
                
                expectation.fulfill()
            })
            
            reaction.on(State.prop.text, { (change) in
                
                XCTAssert(change.oldValue() == "")
                XCTAssert(change.newValue() == "reaction")
                XCTAssert(change.key() == State.prop.text.rawValue)
                XCTAssert(change.store() === store)
                
                expectation2.fulfill()
            })
            
            reaction.on(State.prop.object, { (change) in
                
                XCTAssert( isFluxNil(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == State.prop.object.rawValue)
                XCTAssert(change.store() === store)
                
                expectation3.fulfill()
            })
            
        }
        
        flux.mutate(store,{ (store, commit, abort) in
            store.state.counter = 1
            store.state.text = "reaction"
            store.state.object = aObject
            commit()
        })
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner, binding:store)
        
        flux.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
                XCTAssert(change.newValue() == 2)
            })
        }
        
        flux.mutate(store){ (store) in
           store.state.counter=1
        }.mutate(store) { (store) in
            store.state.counter=2
        }.commit()
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
}
