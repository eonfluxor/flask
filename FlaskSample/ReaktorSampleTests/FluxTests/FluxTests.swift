//
//  FluxTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvflux. All rights reserved.
//

import XCTest
import Reaktor

class FluxorTests: SetupFluxTests {
    

    func testCallback(){
        
        let expectation = self.expectation(description: "testCallback Mutation counter")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        flux.reactor = { owner, reaction in
            
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
            
        }
        
        DispatchQueue.main.async {
            Flux.action(Actions.Count, payload: ["test":"callback"])
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    func testOwner(){
        
        let expectation = self.expectation(description: "testOwner Delegate")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        flux.reactor = { owner, reaction in
            
            reaction.at(store)?.on(State.prop.counter, { (change) in
                owner.reactionMethod(expectation)
            })
            
        }
        
        DispatchQueue.main.async {
            Flux.action(Actions.Count, payload: ["test":"testOwner"])
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testUnbinding(){
        
        let expectation = self.expectation(description: "testUnbinding")
        expectation.isInverted=true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        flux.reactor={owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flux.unbind()
        Flux.action(Actions.Count, payload: ["test":"unbinding"])
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    func testStrongOwner(){
        
        let expectation = self.expectation(description: "testStrongOwner")
        
        let store = self.store!
        let owner:TestOwner? = TestOwner()
        
        weak var flux = Flux.instance(ownedBy:owner!,binding: store)
        
        flux?.reactor = { owner, reaction in}
   
        
        DispatchQueue.main.async {
            
            if flux != nil {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testOwnerDispose(){
        
        let expectation = self.expectation(description: "testOwnerDispose")
        
        let store = self.store!
        var weakOwner:TestOwner? = TestOwner()
        
        weak var flux = Flux.instance(ownedBy:weakOwner!, binding:store)
        
        flux?.reactor = { owner, reaction in}
        
        
        // Calling dispatch after disposing the owner
        // should cause the factory to release this flux
        weakOwner = nil
        
        Flux.action(Actions.Count, payload:  ["test":"ownerDispose"])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  {
            if flux == nil {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    func testChange(){
        
        let expectation = self.expectation(description: "testChange Mutation")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        flux.reactor = { owner, reaction in
            
            reaction.on(State.prop.counter, { (change) in
                
                XCTAssert(change.oldValue() == 0)
                XCTAssert(change.newValue() == 1)
                XCTAssert(change.key() == State.prop.counter.rawValue)
                XCTAssert(change.store() === store)
                
                expectation.fulfill()
            })
            
        }
        
        Flux.action(Actions.Count, payload: ["test":"change"])
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    
    func testGlobalStore(){
        
        let expectation = self.expectation(description: "testGlobalStore testInlineMutation")
        
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner, binding:Stores.test)
        
        flux.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
                XCTAssert(Stores.test.state.counter == 2)
            })
        }
        
        flux.mutate(Stores.test,{ (store) in
            store.state.counter=1
        }).mutate(Stores.test) { (store) in
            store.state.counter=2
            }.commit()
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
        
    }
    
    func testStateInternal(){
        
        let expectation = self.expectation(description: "testStateInternal")
        expectation.isInverted = true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner, binding:store)
        
        flux.reactor = { owner, reaction in
            reaction.on("_internal", { (change) in
                expectation.fulfill()
            })
        }
        
        flux.mutate(store,{ (store, commit, abort) in
            store.state._internal="shouldn't cause mutation"
            commit()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    
}
