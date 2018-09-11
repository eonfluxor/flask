//
//  SerializationTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest
import Reaktor_iOS

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
            state.map = FluxDictionaryRef(dict)
            state.object = FluxRef(NSObject())
            
            let jsonString:String = try FluxSerializer.jsonFromState(state)
            
            let stateDecoded:State = try FluxSerializer.stateFromJson(jsonString)
            
            XCTAssert(state.counter == stateDecoded.counter )
            XCTAssert(state.text == stateDecoded.text )
            XCTAssert(state.map!["foo"] == stateDecoded.map!["foo"] )
            
            let nest:FluxDictionaryRef = state.map!["nest"] as! FluxDictionaryRef
            let nestDecoded:FluxDictionaryRef = stateDecoded.map!["nest"] as! FluxDictionaryRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
