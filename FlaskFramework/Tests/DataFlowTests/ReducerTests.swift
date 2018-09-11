//
//  MutationTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class ChangeTests: XCTestCase {
    
    var oldState:FlaskStateDictionaryType = [:]
    var newState:FlaskStateDictionaryType = [:]
    var changes:FlaskStateDictionaryType = [:]
   
    
    func testNilVsInt(){
        
        oldState["key"] = Lab.Nil
        newState["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
        

        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
        
        oldState["key"] = Lab.Nil
        newState["key"] = 1
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = 1
        newState["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNilVsNSObject(){
        
        
        oldState["key"] = NSObject()
        newState["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = Lab.Nil
        newState["key"] = NSObject()
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        
        oldState["key"] = Lab.Nil
        newState["key"] = NSObject()
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = NSObject()
        newState["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = Lab.Nil
        newState["key"] = NSDictionary()
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = NSDictionary()
        newState["key"] = Lab.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNSObjectVsNSObject(){
        
        let objectA = NSObject()
        let objectB = NSObject()
        
        oldState["key"] = objectA
        newState["key"] = objectA
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
      
        oldState["key"] = objectA
        newState["key"] = objectB
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = objectA
        newState["key"] = objectB
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    

   
    
    
    
}
