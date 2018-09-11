//
//  MutationTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class ChangeTests: XCTestCase {
    
    var oldState:FluxStateDictionaryType = [:]
    var newState:FluxStateDictionaryType = [:]
    var changes:FluxStateDictionaryType = [:]
   
    
    func testNilVsInt(){
        
        oldState["key"] = Flux.Nil
        newState["key"] = Flux.Nil
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
        

        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
        
        oldState["key"] = Flux.Nil
        newState["key"] = 1
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = 1
        newState["key"] = Flux.Nil
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNilVsNSObject(){
        
        
        oldState["key"] = NSObject()
        newState["key"] = Flux.Nil
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = Flux.Nil
        newState["key"] = NSObject()
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        
        oldState["key"] = Flux.Nil
        newState["key"] = NSObject()
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = NSObject()
        newState["key"] = Flux.Nil
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = Flux.Nil
        newState["key"] = NSDictionary()
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = NSDictionary()
        newState["key"] = Flux.Nil
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    
    func testNSObjectVsNSObject(){
        
        let objectA = NSObject()
        let objectB = NSObject()
        
        oldState["key"] = objectA
        newState["key"] = objectA
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 0)
      
        oldState["key"] = objectA
        newState["key"] = objectB
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
        
        oldState["key"] = objectA
        newState["key"] = objectB
        changes = FluxReaction.reduceChanges(oldState, newState)
        XCTAssert(changes.count == 1)
        
    }
    

   
    
    
    
}
