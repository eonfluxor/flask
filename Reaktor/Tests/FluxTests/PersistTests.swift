//
//  archiveTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class archiveTests: SetupFluxTests {
    
    func testarchive(){
        
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
}
