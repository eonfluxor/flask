//
//  NestingTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflux. All rights reserved.
//

import XCTest
import Reaktor_iOS

class NestedStateTests: SetupFluxTests {
    
    func testNestedState(){
        
        let expectation = self.expectation(description: "testFluxDictionaryRef")
        let expectation2 = self.expectation(description: "testFluxDictionaryRef")
        let expectation3 = self.expectation(description: "testFluxDictionaryRef optional(some)")
        let expectation4 = self.expectation(description: "testFluxDictionaryRef optional(nil)")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flux.instance(ownedBy:owner, binding:store)
        
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some"
            ]
            
        ]
        
        let data2:NSDictionary = [:]
        
        let dictRef = FluxDictionaryRef(data)
        let dictRef2 = FluxDictionaryRef(data2)
        
        let firstTest:(@escaping ()->Void)->Void = { next in
            flux.reactor = { owner, reaction in
                reaction.on("map.foo", { (change) in
                    print(change.newValue()!)
                    XCTAssert(change.newValue()=="bar")
                    expectation.fulfill()
                })
                
                reaction.on("map.nest.nest.foo2", { (change) in
                    XCTAssert(change.newValue()=="bar2")
                    expectation2.fulfill()
                })
                
                reaction.on("map.nest.optional", { (change) in
                    print(change.newValue()!)
                    XCTAssert(change.newValue()=="some")
                    expectation3.fulfill()
                })
                
                next()
            }
            
            
            flux.mutate(store,{ (store, commit, abort) in
                store.state.map = dictRef
                commit()
            })
        }
        
        
        let secondTest = {
            
            // now empty all keys
            
            flux.reactor = { owner, reaction in
                reaction.on("map.nest.optional", { (change) in
                    XCTAssert(isFluxNil(change.newValue()))
                    expectation4.fulfill()
                })
            }
            
            flux.mutate(store,{ (store, commit, abort) in
                store.state.map = dictRef2
                commit()
            })
        }
        
        firstTest ( secondTest )
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
