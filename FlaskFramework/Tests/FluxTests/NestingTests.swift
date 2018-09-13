//
//  NestingTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class NestedStateTests: SetupFlaskTests {
    
    func testNestedState(){
        
        let expectation = self.expectation(description: "testFlaskDictRef")
        let expectation2 = self.expectation(description: "testFlaskDictRef")
        let expectation3 = self.expectation(description: "testFlaskDictRef optional(some)")
        let expectation4 = self.expectation(description: "testFlaskDictRef optional(nil)")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner, mixing:substance)
        
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some"
            ]
            
        ]
        
        let data2:NSDictionary = [:]
        
        let dictRef = FlaskDictRef(data)
        let dictRef2 = FlaskDictRef(data2)
        
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
                substance.stateMix.map = dictRef
            }.react()
        }
        
        
        let secondTest = {
            
            // now empty all keys
            
            flask.reactor = { owner, reaction in
                reaction.on("map.nest.optional", { (change) in
                    XCTAssert(isNilorNull(change.newValue()))
                    expectation4.fulfill()
                })
            }
            
            flask.mix(substance) { (substance) in
                substance.stateMix.map = dictRef2
            }.react()
        }
        
        firstTest ( secondTest )
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
