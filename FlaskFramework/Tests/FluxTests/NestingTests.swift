//
//  NestingTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class NestedAtomTests: SetupFlaskTests {
    
    func testNestedAtom(){
        
        let expectation = self.expectation(description: "testLabDictRef")
        let expectation2 = self.expectation(description: "testLabDictRef")
        let expectation3 = self.expectation(description: "testLabDictRef optional(some)")
        let expectation4 = self.expectation(description: "testLabDictRef optional(nil)")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:substance)
        
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some"
            ]
            
        ]
        
        let data2:NSDictionary = [:]
        
        let dictRef = LabDictRef(data)
        let dictRef2 = LabDictRef(data2)
        
        let firstTest:(@escaping ()->Void)->Void = { next in
            flask.reactor = { owner, reaction in
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
            
            
            flask.mix(substance){ (substance) in
                substance.atoms.map = dictRef
            }.react()
        }
        
        
        let secondTest = {
            
            // now empty all keys
            
            flask.reactor = { owner, reaction in
                reaction.on("map.nest.optional", { (change) in
                    XCTAssert(isLabNil(change.newValue()))
                    expectation4.fulfill()
                })
            }
            
            flask.mix(substance) { (substance) in
                substance.atoms.map = dictRef2
            }.react()
        }
        
        firstTest ( secondTest )
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
