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
                substance.prop.map = dictRef
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
                substance.prop.map = dictRef2
                }.react()
        }
        
        firstTest ( secondTest )
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testStruct(){
        
        let expectation = self.expectation(description: "testStruct")
        let expectation2 = self.expectation(description: "testStruct")
        let expectation3 = self.expectation(description: "testStruct")
        
        struct nestedTestStruct:Codable{
            var foo = "bar"
        }
        
        struct testStruct:Codable{
            var counter = 10
            var nest = nestedTestStruct()
        }
        
        struct state : State{
            var info = testStruct()
        }
        
        let mySubstance = NewSubstance(definedBy: state.self)
        
        
        let owner:TestOwner = TestOwner()
        let flask = Flask.instance(attachedTo:owner, mixing:mySubstance)

        
        flask.reactor = { owner, reaction in
            reaction.on("info", { (change) in
                expectation.fulfill()
            })
            reaction.on("info.counter", { (change) in
                expectation2.fulfill()
            })
            reaction.on("info.nest.foo", { (change) in
                expectation3.fulfill()
            })
        }
        
        flask.mix(mySubstance) { (substance) in
            substance.prop.info.counter = 90
            substance.prop.info.nest.foo = "var"
        }.andReact()
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
        
}
