//
//  LockTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class LockTests: SetupFlaskTests {
    
    func testLock(){
        
        let expectation = self.expectation(description: "testLock Mutation")
        let expectation2 = self.expectation(description: "testLock Mutation Ignored")
        expectation2.isInverted=true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        var calls = 0
        
        flask.reactor = { owner, reaction in
            
            reaction.at(store)?.on(State.prop.counter, { (change) in
                
                if calls == 0 {
                    expectation.fulfill()
                }else{
                    expectation2.fulfill()
                }
                
                calls += 1
                
                _ = Lab.lock()
                Lab.action(Actions.Count, payload:  ["test":"testLock"])
                
            })
        }
        
        DispatchQueue.main.async {
            Lab.action(Actions.Count, payload: ["test":"testLock"])
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
        Lab.disposeDispatchQueue()
    }
    
    
    func testLockRelease(){
        
        let expectation = self.expectation(description: "testLockRelease Mutation")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        flask.reactor = { owner, reaction in
            reaction.at(store)?.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        // the action won't be dispatched until both locks are released
        
        let lock  = Lab.lock()
        let lock2  = Lab.lock()
        Lab.action(Actions.Count, payload:  ["test":"testLockRelease"])
        
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
        let flask = Lab.flask(ownedBy:owner,binding:store)
        
        flask.reactor = { owner, reaction in
            reaction.at(store)?.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
            reaction.at(store)?.on(State.prop.text, { (change) in
                expectation2.fulfill()
            })
        }
        
        let lock  = Lab.lock(action:Actions.Count, payload:  ["test":"testLockActon count"])
       
        //this should be performed after the lock releases
        Lab.action(Actions.Text, payload:  ["test":"testLockAction text"])
        
        wait(for: [expectation], timeout: 2)
        
        lock.release()
        wait(for: [expectation2], timeout: 2)
        
        
    }
    
}
