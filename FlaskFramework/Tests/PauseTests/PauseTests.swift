//
//  PauseTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class PauseTests: SetupFlaskTests {
    
    func testPause(){
        
        let expectation = self.expectation(description: "testPause Mix")
        let expectation2 = self.expectation(description: "testPause Mix Ignored")
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
                
                _ = Flux.pause()
                Flux.transmute(AppActions.Count, payload:  ["test":"testPause"])
                
            })
        }
        
        DispatchQueue.main.async {
            Flux.transmute(AppActions.Count, payload: ["test":"testPause"])
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
        Flux.purgeBusQueue()
    }
    
    
    func testPauseRelease(){
        
        let expectation = self.expectation(description: "testPauseRelease Mix")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner,filling:store)
        
        flask.reactor = { owner, reaction in
            reaction.at(store)?.on(AppState.named.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        // the bus won't be mixed until both pauses are released
        
        let pause  = Flux.pause()
        let pause2  = Flux.pause()
        Flux.transmute(AppActions.Count, payload:  ["test":"testPauseRelease"])
        
        DispatchQueue.main.async {
            pause.release()
            DispatchQueue.main.async {
                pause2.release()
            }
            
        }
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testPauseAction(){
        
        let expectation = self.expectation(description: "testPauseRelease Mix")
        let expectation2 = self.expectation(description: "testPauseRelease Mix Ignored")
     
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flask = Flux.flask(ownedBy:owner,filling:store)
        
        flask.reactor = { owner, reaction in
            reaction.at(store)?.on(AppState.named.counter, { (change) in
                
                reaction.onPause?.release()
                expectation.fulfill()
           
            })
            reaction.at(store)?.on(AppState.named.text, { (change) in
                expectation2.fulfill()
            })
        }
        
        Flux.pause(fillingg:AppActions.Count, payload:  ["test":"testPauseActon count"])
       
        //this should be performed after the pause releases
        Flux.transmute(AppActions.Text, payload:  ["test":"testPauseAction text"])
        
        wait(for: [expectation], timeout: 2)
        
       
        wait(for: [expectation2], timeout: 2)
        
        
    }
    
}
