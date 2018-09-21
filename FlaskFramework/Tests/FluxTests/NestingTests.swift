//
//  NestingTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvreactor. All rights reserved.
//

import XCTest


class NestedStateTests: SetupFlaskTests {
    
    
    
    func testNestedState(){
        
        let expectation = self.expectation(description: "testFlaskDictRef")
        let expectation2 = self.expectation(description: "testFlaskDictRef")
        let expectation3 = self.expectation(description: "testFlaskDictRef optional(some)")
        let expectation4 = self.expectation(description: "testFlaskDictRef optional(nil)")
        let expectation5 = self.expectation(description: "testFlaskDictRef object")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:substance)
        
        let object = NSObject()
        
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some",
                "object":object
            ]
            
        ]
        
        let data2:NSDictionary = [:]
        
        let dictRef = FlaskDictRef(data)
        let dictRef2 = FlaskDictRef(data2)
        
        let firstTest:(@escaping ()->Void)->Void = { next in
            reactor.handler = { owner, reaction in
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
                    XCTAssert(change.newValue()=="some")
                    expectation3.fulfill()
                })
                
                reaction.on("map.nest.object", { (change) in
                    XCTAssert(change.newValue()==object)
                    expectation5.fulfill()
                })
                
                
                next()
            }
            
            
            reactor.mix(substance){ (substance) in
                substance.prop.map = dictRef
                }.react()
        }
        
        
        let secondTest = {
            
            // now empty all keys
            
            reactor.handler = { owner, reaction in
                reaction.on("map.nest.optional", { (change) in
                    XCTAssert(isNilorNull(change.newValue()))
                    expectation4.fulfill()
                })
            }
            
            reactor.mix(substance) { (substance) in
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
            var object = FlaskNSRef(NSObject())
        }
        
        struct testStruct:Codable{
            var counter = 10
            var nest = nestedTestStruct()
        }
        
        struct state : State{
            var info = testStruct()
        }
        
        let NAME = "subtanceTest\( NSDate().timeIntervalSince1970)"
        let mySubstance = Flask.newSubstance(definedBy: state.self,named:NAME, archive:false)
        mySubstance.shouldArchive = true
        
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:mySubstance)

        
        reactor.handler = { owner, reaction in
            
            mySubstance.archiveNow()
            
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
        
        reactor.mix(mySubstance) { (substance) in
            substance.prop.info.counter = 90
            substance.prop.info.nest.foo = "mutated"
            }.andReact()
        
        wait(for: [expectation,expectation2,expectation3], timeout: 2)
        
        let expectation4 = self.expectation(description: "must preserve after archive")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           
            let archivedSubstance = Flask.newSubstance(definedBy: state.self,named:NAME,archive:true)
            XCTAssert(archivedSubstance.state.info.nest.foo == "mutated", "Must preserve value")
            expectation4.fulfill()
        }
        
        wait(for: [expectation4], timeout: 4)
    }
    
        
}
