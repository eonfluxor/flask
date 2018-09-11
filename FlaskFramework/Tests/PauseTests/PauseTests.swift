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
        
        let expectation = self.expectation(description: "testLock Transmute")
        let expectation2 = self.expectation(description: "testLock Transmute Ignored")
        expectation2.isInverted=true
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner,filling:store)
        
        var calls = 0
        
        flask.reactor = { owner, reaction in
            
            reaction.at(store)?.on(AppState.named.counter, { (change) in
                
                if calls == 0 {
                    expectation.fulfill()
                }else{
                    expectation2.fulfill()
                }
                
                calls += 1
                
                _ = Flux.lock()
                Flux.transmute(AppEvents.Count, payload:  ["test":"testLock"])
                
            })
        }
        
        DispatchQueue.main.async {
            Flux.transmute(AppEvents.Count, payload: ["test":"testLock"])
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
        Flux.purgeBusQueue()
    }
    
    
    func testLockRelease(){
        
        let expectation = self.expectation(description: "testLockRelease Transmute")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner,filling:store)
        
        flask.reactor = { owner, reaction in
            reaction.at(store)?.on(AppState.named.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        // the bus won't be mixed until both locks are released
        
        let lock  = Flux.lock()
        let lock2  = Flux.lock()
        Flux.transmute(AppEvents.Count, payload:  ["test":"testLockRelease"])
        
        DispatchQueue.main.async {
            lock.release()
            DispatchQueue.main.async {
                lock2.release()
            }
            
        }
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testLockAction(){
        
        let expectation = self.expectation(description: "testLockRelease Transmute")
        let expectation2 = self.expectation(description: "testLockRelease Transmute Ignored")
     
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner,filling:store)
        
        flask.reactor = { owner, reaction in
            reaction.at(store)?.on(AppState.named.counter, { (change) in
                
                reaction.onLock?.release()
                expectation.fulfill()
           
            })
            reaction.at(store)?.on(AppState.named.text, { (change) in
                expectation2.fulfill()
            })
        }
        
        Flux.lock(withEvent:AppEvents.Count, payload:  ["test":"testLockActon count"])
       
        //this should be performed after the lock releases
        Flux.transmute(AppEvents.Text, payload:  ["test":"testLockAction text"])
        
        wait(for: [expectation], timeout: 2)
        
       
        wait(for: [expectation2], timeout: 2)
        
        
    }
    
}
