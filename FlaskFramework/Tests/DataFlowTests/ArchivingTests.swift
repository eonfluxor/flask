//
//  archiveTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class archiveTests: SetupFlaskTests {
    
    func testarchive(){
        
        let expectation = self.expectation(description: "archive value")
        let expectationUnarchive = self.expectation(description: "value must persist")
        
        let expectedValue = Int(Date().timeIntervalSince1970)
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flask.instance(ownedBy:owner, binding:store)
        
        flux.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flux.mutate(store){ (store) in
            store.state.counter=expectedValue
        }.commit()
        
        wait(for: [expectation], timeout: 1)
        
        flux.unbind()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            let anotherStore = Store()
            XCTAssert(anotherStore.state.counter == expectedValue)
            anotherStore.purgeArchive()
            
            expectationUnarchive.fulfill()
        }
        
        wait(for: [expectationUnarchive], timeout: 5)
        
    }
}
