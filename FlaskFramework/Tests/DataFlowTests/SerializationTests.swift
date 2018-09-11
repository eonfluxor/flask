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
            
            var state:State = State()
            state.counter = 666
            state.text = "hello world"
            state.map = FlaskDictionaryRef(dict)
            state.object = FlaskRef(NSObject())
            
            let jsonString:String = try FlaskSerializer.jsonFromState(state)
            
            let stateDecoded:State = try FlaskSerializer.stateFromJson(jsonString)
            
            XCTAssert(state.counter == stateDecoded.counter )
            XCTAssert(state.text == stateDecoded.text )
            XCTAssert(state.map!["foo"] == stateDecoded.map!["foo"] )
            
            let nest:FlaskDictionaryRef = state.map!["nest"] as! FlaskDictionaryRef
            let nestDecoded:FlaskDictionaryRef = stateDecoded.map!["nest"] as! FlaskDictionaryRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
