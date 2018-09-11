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
        
        let expectation = self.expectation(description: "testLabDictionaryRef")
        let expectation2 = self.expectation(description: "testLabDictionaryRef")
        let expectation3 = self.expectation(description: "testLabDictionaryRef optional(some)")
        let expectation4 = self.expectation(description: "testLabDictionaryRef optional(nil)")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:molecule)
        
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some"
            ]
            
        ]
        
        let data2:NSDictionary = [:]
        
        let dictRef = LabDictionaryRef(data)
        let dictRef2 = LabDictionaryRef(data2)
        
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
            
            
            flask.mix(molecule,{ (molecule, commit, abort) in
                molecule.atoms.map = dictRef
                commit()
            })
        }
        
        
        let secondTest = {
            
            // now empty all keys
            
            flask.reactor = { owner, reaction in
                reaction.on("map.nest.optional", { (change) in
                    XCTAssert(isLabNil(change.newValue()))
                    expectation4.fulfill()
                })
            }
            
            flask.mix(molecule,{ (molecule, commit, abort) in
                molecule.atoms.map = dictRef2
                commit()
            })
        }
        
        firstTest ( secondTest )
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
