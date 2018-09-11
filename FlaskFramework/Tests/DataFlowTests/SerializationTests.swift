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
            atoms.map = LabDictionaryRef(dict)
            atoms.object = LabRef(NSObject())
            
            let jsonString:String = try LabSerializer.jsonFromAtom(atoms)
            
            let atomsDecoded:Atom = try LabSerializer.atomsFromJson(jsonString)
            
            XCTAssert(atoms.counter == atomsDecoded.counter )
            XCTAssert(atoms.text == atomsDecoded.text )
            XCTAssert(atoms.map!["foo"] == atomsDecoded.map!["foo"] )
            
            let nest:LabDictionaryRef = atoms.map!["nest"] as! LabDictionaryRef
            let nestDecoded:LabDictionaryRef = atomsDecoded.map!["nest"] as! LabDictionaryRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
