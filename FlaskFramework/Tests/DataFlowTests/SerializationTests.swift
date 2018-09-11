//
//  SerializationTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class SerializationTests: XCTestCase {

    
    func testAtomSerialization(){
        
        do {
            let dict:NSDictionary = [
                "foo":"bar",
                "nest":["foo":"bar"]
            ]
            
            var atoms:Atom = Atom()
            atoms.counter = 666
            atoms.text = "hello world"
            atoms.map = FlaskDictionaryRef(dict)
            atoms.object = FlaskRef(NSObject())
            
            let jsonString:String = try FlaskSerializer.jsonFromAtom(atoms)
            
            let atomsDecoded:Atom = try FlaskSerializer.atomsFromJson(jsonString)
            
            XCTAssert(atoms.counter == atomsDecoded.counter )
            XCTAssert(atoms.text == atomsDecoded.text )
            XCTAssert(atoms.map!["foo"] == atomsDecoded.map!["foo"] )
            
            let nest:FlaskDictionaryRef = atoms.map!["nest"] as! FlaskDictionaryRef
            let nestDecoded:FlaskDictionaryRef = atomsDecoded.map!["nest"] as! FlaskDictionaryRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
