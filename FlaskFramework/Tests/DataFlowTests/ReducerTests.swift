//
//  MixTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class ChangeTests: XCTestCase {
    
    var oldAtom:LabDictType = [:]
    var newAtom:LabDictType = [:]
    var changes:LabDictType = [:]
   
    
    func testNilVsInt(){
        
        oldAtom["key"] = Lab.Nil
        newAtom["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 0)
        

        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 0)
        
        oldAtom["key"] = Lab.Nil
        newAtom["key"] = 1
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        oldAtom["key"] = 1
        newAtom["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNilVsNSObject(){
        
        
        oldAtom["key"] = NSObject()
        newAtom["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        oldAtom["key"] = Lab.Nil
        newAtom["key"] = NSObject()
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        
        oldAtom["key"] = Lab.Nil
        newAtom["key"] = NSObject()
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        oldAtom["key"] = NSObject()
        newAtom["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        oldAtom["key"] = Lab.Nil
        newAtom["key"] = NSDictionary()
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        oldAtom["key"] = NSDictionary()
        newAtom["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNSObjectVsNSObject(){
        
        let objectA = NSObject()
        let objectB = NSObject()
        
        oldAtom["key"] = objectA
        newAtom["key"] = objectA
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 0)
      
        oldAtom["key"] = objectA
        newAtom["key"] = objectB
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
        
        oldAtom["key"] = objectA
        newAtom["key"] = objectB
        changes = FlaskReaction.reduceChanges(oldAtom, newAtom)
        XCTAssert(changes.count == 1)
        
    }
    

   
    
    
    
}
