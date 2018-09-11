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
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner, filling:store)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
      
        
        flask.transmute(store){ (store) in
            store.state.counter=1
            
        }.transmute(store) { (store) in
            store.state.counter=2
        }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner,filling:store)
        
        let object = NSObject()
        let aObject = FluxRef( object )
        
        
        flask.reactor = { owner, reaction in
            
            reaction.on(AppState.named.counter, { (change) in
                
                let oldValue:Int? = change.oldValue()
                let newValue:Int? = change.newValue()
                XCTAssert(oldValue == 0)
                XCTAssert(newValue == 1)
                XCTAssert(change.key() == AppState.named.counter.rawValue)
                XCTAssert(change.store() === store)
                
                expectation.fulfill()
            })
            
            reaction.on(AppState.named.text, { (change) in
                
                XCTAssert(change.oldValue() == "")
                XCTAssert(change.newValue() == "reaction")
                XCTAssert(change.key() == AppState.named.text.rawValue)
                XCTAssert(change.store() === store)
                
                expectation2.fulfill()
            })
            
            reaction.on(AppState.named.object, { (change) in
                
                XCTAssert( isFluxNil(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == AppState.named.object.rawValue)
                XCTAssert(change.store() === store)
                
                expectation3.fulfill()
            })
            
        }
        
        flask.transmute(store) { (store) in
            store.state.counter = 1
            store.state.text = "reaction"
            store.state.object = aObject
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner, filling:store)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppState.named.counter, { (change) in
                expectation.fulfill()
                XCTAssert(change.newValue() == 2)
            })
        }
        
        flask.transmute(store){ (store) in
            store.state.counter=1
        }.transmute(store) { (store) in
            store.state.counter=2
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
}
