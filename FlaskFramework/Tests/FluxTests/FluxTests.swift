//
//  FlaskTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class FlaskReactorTests: SetupFlaskTests {
    

    func testCallback(){
        
        let expectation = self.expectation(description: "testCallback Mutation counter")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        flask.reactor = { owner, reaction in
            
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
            
        }
        
        DispatchQueue.main.async {
            Lab.action(Actions.Count, payload: ["test":"callback"])
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    func testOwner(){
        
        let expectation = self.expectation(description: "testOwner Delegate")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        flask.reactor = { owner, reaction in
            
            reaction.at(store)?.on(State.prop.counter, { (change) in
                owner.reactionMethod(expectation)
            })
            
        }
        
        DispatchQueue.main.async {
            Lab.action(Actions.Count, payload: ["test":"testOwner"])
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testUnbinding(){
        
        let expectation = self.expectation(description: "testUnbinding")
        expectation.isInverted=true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        flask.reactor={owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flask.unbind()
        Lab.action(Actions.Count, payload: ["test":"unbinding"])
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    func testStrongOwner(){
        
        let expectation = self.expectation(description: "testStrongOwner")
        
        let store = self.store!
        let owner:TestOwner? = TestOwner()
        
        weak var flask = Lab.flask(ownedBy:owner!)
        flask?.stores = [store]
        flask?.reactor = { owner, reaction in}
        flask?.bind()
        
        DispatchQueue.main.async {
            
            if flask != nil {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testOwnerDispose(){
        
        let expectation = self.expectation(description: "testOwnerDispose")
        
        let store = self.store!
        var weakOwner:TestOwner? = TestOwner()
        
        weak var flask = Lab.flask(ownedBy:weakOwner!)
        flask?.stores = [store]
        flask?.reactor = { owner, reaction in}
        flask?.bind()
        
        // Calling dispatch after disposing the owner
        // should cause the factory to release this flask
        weakOwner = nil
        
        Lab.action(Actions.Count, payload:  ["test":"ownerDispose"])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  {
            if flask == nil {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    func testChange(){
        
        let expectation = self.expectation(description: "testChange Mutation")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        flask.reactor = { owner, reaction in
            
            reaction.on(State.prop.counter, { (change) in
                
                XCTAssert(change.oldValue() == 0)
                XCTAssert(change.newValue() == 1)
                XCTAssert(change.key() == State.prop.counter.rawValue)
                XCTAssert(change.store() === store)
                
                expectation.fulfill()
            })
            
        }
        
        Lab.action(Actions.Count, payload: ["test":"change"])
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    
    func testGlobalApp(){
        
        let expectation = self.expectation(description: "testGlobalMolecule testInlineMutation")
        
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, binding:Molecules.test)
        
        flask.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
                XCTAssert(Molecules.test.state.counter == 2)
            })
        }
        
        flask.mutate(Molecules.test,{ (store) in
            store.state.counter=1
        }).mutate(Molecules.test) { (store) in
            store.state.counter=2
            }.commit()
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
        
    }
    
    func testStateInternal(){
        
        let expectation = self.expectation(description: "testStateInternal")
        expectation.isInverted = true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, binding:store)
        
        flask.reactor = { owner, reaction in
            reaction.on("_internal", { (change) in
                expectation.fulfill()
            })
        }
        
        flask.mutate(store,{ (store, commit, abort) in
            store.state._internal="shouldn't cause mutation"
            commit()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    
}
