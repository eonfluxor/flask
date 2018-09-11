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
            
            var atoms:Atoms = Atoms()
            atoms.counter = 666
            atoms.text = "hello world"
            atoms.map = LabDictRef(dict)
            atoms.object = LabRef(NSObject())
            
            let jsonString:String = try MoleculeSerializer.jsonFromAtoms(atoms)
            
            let atomsDecoded:Atoms = try MoleculeSerializer.atomsFromJson(jsonString)
            
            XCTAssert(atoms.counter == atomsDecoded.counter )
            XCTAssert(atoms.text == atomsDecoded.text )
            XCTAssert(atoms.map!["foo"] == atomsDecoded.map!["foo"] )
            
            let nest:LabDictRef = atoms.map!["nest"] as! LabDictRef
            let nestDecoded:LabDictRef = atomsDecoded.map!["nest"] as! LabDictRef
            
            XCTAssert(nest["foo"] == nestDecoded["foo"] )
            
        } catch {
            
        }
    }
}
