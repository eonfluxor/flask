//
//  SerializationTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class SerializationTests: XCTestCase {

    
    func testStateSerialization(){
        
        do {
            let dict:NSDictionary = [
                "foo":"bar",
                "nest":["foo":"bar"]
            ]
            
            var state:AppState = AppState()
            state.counter = 666
            state.text = "hello world"
            state.map = FlaskDictRef(dict)
            state.object = FlaskRef(NSObject())
            
            let jsonString:String = try SubstanceSerializer.jsonFromState(state)
            
            let stateDecoded:AppState = try SubstanceSerializer.stateFromJson(jsonString)
            
            XCTAssert(state.counter == stateDecoded.counter )
            XCTAssert(state.text == stateDecoded.text )
            XCTAssert(state.map!["foo"] == stateDecoded.map!["foo"] )
            
            let nest:FlaskDictRef = state.map!["nest"] as! FlaskDictRef
            let nestDecoded:FlaskDictRef = stateDecoded.map!["nest"] as! FlaskDictRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
