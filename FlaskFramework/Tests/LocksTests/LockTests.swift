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
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        var calls = 0
        
        flask.reactor = { owner, reaction in
            
            reaction.at(molecule)?.on(AppAtoms.named.counter, { (change) in
                
                if calls == 0 {
                    expectation.fulfill()
                }else{
                    expectation2.fulfill()
                }
                
                calls += 1
                
                _ = Lab.pause()
                Lab.applyMixer(AppMixers.Count, payload:  ["test":"testPause"])
                
            })
        }
        
        DispatchQueue.main.async {
            Lab.applyMixer(AppMixers.Count, payload: ["test":"testPause"])
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
        Lab.disposeDispatchQueue()
    }
    
    
    func testPauseRelease(){
        
        let expectation = self.expectation(description: "testPauseRelease Mix")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.at(molecule)?.on(AppAtoms.named.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        // the mixer won't be formulateed until both pauses are released
        
        let pause  = Lab.pause()
        let pause2  = Lab.pause()
        Lab.applyMixer(AppMixers.Count, payload:  ["test":"testPauseRelease"])
        
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
     
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.at(molecule)?.on(AppAtoms.named.counter, { (change) in
                expectation.fulfill()
            })
            reaction.at(molecule)?.on(AppAtoms.named.text, { (change) in
                expectation2.fulfill()
            })
        }
        
        let pause = Lab.pause(mixing:AppMixers.Count, payload:  ["test":"testPauseActon count"])
       
        //this should be performed after the pause releases
        Lab.applyMixer(AppMixers.Text, payload:  ["test":"testPauseAction text"])
        
        wait(for: [expectation], timeout: 2)
        
        pause.release()
        wait(for: [expectation2], timeout: 2)
        
        
    }
    
}
