//
//  TransmuteTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class ChangeTests: XCTestCase {
    
    var oldState:FluxDictType = [:]
    var newState:FluxDictType = [:]
    var changes:FluxDictType = [:]
   
    
    func testNilVsInt(){
        
        oldState["key"] = Flux.Nil
        newState["key"] = Flux.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
        

        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
        
        oldState["key"] = Flux.Nil
        newState["key"] = 1
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = 1
        newState["key"] = Flux.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNilVsNSObject(){
        
        
        oldState["key"] = NSObject()
        newState["key"] = Flux.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = Flux.Nil
        newState["key"] = NSObject()
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        
        oldState["key"] = Flux.Nil
        newState["key"] = NSObject()
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = NSObject()
        newState["key"] = Flux.Nil
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = Flux.Nil
        newState["key"] = NSDictionary()
        changes = FlaskReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = NSDictionary()
        newState["key"] = Flux.Nil
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
