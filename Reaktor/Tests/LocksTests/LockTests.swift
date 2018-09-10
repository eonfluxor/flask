//
//  LockTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflux. All rights reserved.
//

import XCTest


class LockTests: SetupFluxTests {
    
    func testLock(){
        
        let expectation = self.expectation(description: "testLock Mutation")
        let expectation2 = self.expectation(description: "testLock Mutation Ignored")
        expectation2.isInverted=true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        var calls = 0
        
        flux.reactor = { owner, reaction in
            
            reaction.at(store)?.on(State.prop.counter, { (change) in
                
                if calls == 0 {
                    expectation.fulfill()
                }else{
                    expectation2.fulfill()
                }
                
                calls += 1
                
                _ = Flux.lock()
                Flux.action(Actions.Count, payload:  ["test":"testLock"])
                
            })
        }
        
        DispatchQueue.main.async {
            Flux.action(Actions.Count, payload: ["test":"testLock"])
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
        Flux.disposeDispatchQueue()
    }
    
    
    func testLockRelease(){
        
        let expectation = self.expectation(description: "testLockRelease Mutation")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        flux.reactor = { owner, reaction in
            reaction.at(store)?.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        // the action won't be dispatched until both locks are released
        
        let lock  = Flux.lock()
        let lock2  = Flux.lock()
        Flux.action(Actions.Count, payload:  ["test":"testLockRelease"])
        
        DispatchQueue.main.async {
            lock.release()
            DispatchQueue.main.async {
                lock2.release()
            }
            
        }
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testLockAction(){
        
        let expectation = self.expectation(description: "testLockRelease Mutation")
        let expectation2 = self.expectation(description: "testLockRelease Mutation Ignored")
     
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner,binding:store)
        
        flux.reactor = { owner, reaction in
            reaction.at(store)?.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
            reaction.at(store)?.on(State.prop.text, { (change) in
                expectation2.fulfill()
            })
        }
        
        let lock  = Flux.lock(action:Actions.Count, payload:  ["test":"testLockActon count"])
       
        //this should be performed after the lock releases
        Flux.action(Actions.Text, payload:  ["test":"testLockAction text"])
        
        wait(for: [expectation], timeout: 2)
        
        lock.release()
        wait(for: [expectation2], timeout: 2)
        
        
    }
    
}
