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
            
            var states:AppState = AppState()
            states.counter = 666
            states.text = "hello world"
            states.map = LabDictRef(dict)
            states.object = LabRef(NSObject())
            
            let jsonString:String = try SubstanceSerializer.jsonFromStates(states)
            
            let statesDecoded:AppState = try SubstanceSerializer.statesFromJson(jsonString)
            
            XCTAssert(states.counter == statesDecoded.counter )
            XCTAssert(states.text == statesDecoded.text )
            XCTAssert(states.map!["foo"] == statesDecoded.map!["foo"] )
            
            let nest:LabDictRef = states.map!["nest"] as! LabDictRef
            let nestDecoded:LabDictRef = statesDecoded.map!["nest"] as! LabDictRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
