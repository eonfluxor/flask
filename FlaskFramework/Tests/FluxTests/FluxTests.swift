//
//  FlaskTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class FlaskTests: SetupFlaskTests {
    

    func testCallback(){
        
        let expectation = self.expectation(description: "testCallback Mix counter")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        flask.reactor = { owner, reaction in
            
            reaction.on(Atom.atom.counter, { (change) in
                expectation.fulfill()
            })
            
        }
        
        DispatchQueue.main.async {
            Lab.mix(Mixers.Count, payload: ["test":"callback"])
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    func testOwner(){
        
        let expectation = self.expectation(description: "testOwner Delegate")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        flask.reactor = { owner, reaction in
            
            reaction.at(molecule)?.on(Atom.atom.counter, { (change) in
                owner.reactionMethod(expectation)
            })
            
        }
        
        DispatchQueue.main.async {
            Lab.mix(Mixers.Count, payload: ["test":"testOwner"])
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testUnmixin(){
        
        let expectation = self.expectation(description: "testUnmixin")
        expectation.isInverted=true
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        flask.reactor={owner, reaction in
            reaction.on(Atom.atom.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        flask.unbind()
        Lab.mix(Mixers.Count, payload: ["test":"unmixin"])
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    func testStrongOwner(){
        
        let expectation = self.expectation(description: "testStrongOwner")
        
        let molecule = self.molecule!
        let owner:TestOwner? = TestOwner()
        
        weak var flask = Lab.flask(ownedBy:owner!)
        flask?.molecules = [molecule]
        flask?.reactor = { owner, reaction in}
        flask?.bind()
        
        DispatchQueue.main.async {
            
            if flask != nil {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testOwnerDispose(){
        
        let expectation = self.expectation(description: "testOwnerDispose")
        
        let molecule = self.molecule!
        var weakOwner:TestOwner? = TestOwner()
        
        weak var flask = Lab.flask(ownedBy:weakOwner!)
        flask?.molecules = [molecule]
        flask?.reactor = { owner, reaction in}
        flask?.bind()
        
        // Calling dispatch after disposing the owner
        // should cause the factory to release this flask
        weakOwner = nil
        
        Lab.mix(Mixers.Count, payload:  ["test":"ownerDispose"])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  {
            if flask == nil {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    func testChange(){
        
        let expectation = self.expectation(description: "testChange Mix")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        flask.reactor = { owner, reaction in
            
            reaction.on(Atom.atom.counter, { (change) in
                
                XCTAssert(change.oldValue() == 0)
                XCTAssert(change.newValue() == 1)
                XCTAssert(change.key() == Atom.atom.counter.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation.fulfill()
            })
            
        }
        
        Lab.mix(Mixers.Count, payload: ["test":"change"])
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
    
    
    func testGlobalApp(){
        
        let expectation = self.expectation(description: "testGlobalMolecule testInlineMix")
        
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:Molecules.app)
        
        flask.reactor = { owner, reaction in
            reaction.on(Atom.atom.counter, { (change) in
                expectation.fulfill()
                XCTAssert(Molecules.app.atoms.counter == 2)
            })
        }
        
        flask.mix(Molecules.app,{ (molecule) in
            molecule.atoms.counter=1
        }).mix(Molecules.app) { (molecule) in
            molecule.atoms.counter=2
            }.commit()
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
        
    }
    
    func testAtomInternal(){
        
        let expectation = self.expectation(description: "testAtomInternal")
        expectation.isInverted = true
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.on("_internal", { (change) in
                expectation.fulfill()
            })
        }
        
        flask.mix(molecule,{ (molecule, commit, abort) in
            molecule.atoms._internal="shouldn't cause mix"
            commit()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    
}
