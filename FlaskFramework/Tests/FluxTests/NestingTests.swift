//
//  NestingTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflux. All rights reserved.
//

import XCTest


class NestedStateTests: SetupFlaskTests {
    
    func testNestedState(){
        
        let expectation = self.expectation(description: "testFlaskDictionaryRef")
        let expectation2 = self.expectation(description: "testFlaskDictionaryRef")
        let expectation3 = self.expectation(description: "testFlaskDictionaryRef optional(some)")
        let expectation4 = self.expectation(description: "testFlaskDictionaryRef optional(nil)")
        
        let store = self.store!
        let owner:TestOwner = TestOwner()
        let flux = Flask.instance(ownedBy:owner, binding:store)
        
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some"
            ]
            
        ]
        
        let data2:NSDictionary = [:]
        
        let dictRef = FlaskDictionaryRef(data)
        let dictRef2 = FlaskDictionaryRef(data2)
        
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
                    XCTAssert(isFlaskNil(change.newValue()))
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
