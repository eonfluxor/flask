//
//  ChainTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class ChainingTests: SetupFlaskTests {

    func testInlineMix(){
        
        let expectation = self.expectation(description: "testInlineMix")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppAtoms.named.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
      
        
        flask.mix(molecule){ (molecule) in
            molecule.atoms.counter=1
            
        }.mix(molecule) { (molecule) in
            molecule.atoms.counter=2
        }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        let object = NSObject()
        let aObject = LabRef( object )
        
        
        flask.reactor = { owner, reaction in
            
            reaction.on(AppAtoms.named.counter, { (change) in
                
                let oldValue:Int? = change.oldValue()
                let newValue:Int? = change.newValue()
                XCTAssert(oldValue == 0)
                XCTAssert(newValue == 1)
                XCTAssert(change.key() == AppAtoms.named.counter.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation.fulfill()
            })
            
            reaction.on(AppAtoms.named.text, { (change) in
                
                XCTAssert(change.oldValue() == "")
                XCTAssert(change.newValue() == "reaction")
                XCTAssert(change.key() == AppAtoms.named.text.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation2.fulfill()
            })
            
            reaction.on(AppAtoms.named.object, { (change) in
                
                XCTAssert( isLabNil(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == AppAtoms.named.object.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation3.fulfill()
            })
            
        }
        
        flask.mix(molecule) { (molecule) in
            molecule.atoms.counter = 1
            molecule.atoms.text = "reaction"
            molecule.atoms.object = aObject
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.on(AppAtoms.named.counter, { (change) in
                expectation.fulfill()
                XCTAssert(change.newValue() == 2)
            })
        }
        
        flask.mix(molecule){ (molecule) in
            molecule.atoms.counter=1
        }.mix(molecule) { (molecule) in
            molecule.atoms.counter=2
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
}
