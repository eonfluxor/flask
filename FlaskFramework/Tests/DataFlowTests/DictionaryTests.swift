//
//  ReferenceTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

import XCTest


class DictionaryTests: XCTestCase {
    
    func testDictionaryRef(){
        
        let object = NSObject()
        let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "nest":["foo2":"bar2"],
                "optional":"some",
                "object": object,
                "none":Flask.Null
            ],
            "array":[1,2,3]
        ]
        
        let dictRef = FlaskDictRef(data)
        let nest:FlaskDictRef? = dictRef["nest"] as! FlaskDictRef?
        
        //structure
        XCTAssert((nest != nil))
        XCTAssert(dictRef.count() == 3)
        XCTAssert(nest!.count() == 4)
        
        // nested value
        XCTAssert((nest!["optional"] as? String) == "some" )
        XCTAssert((nest!["object"] as NSObject?) == object )
        XCTAssert((dictRef["array"] as? NSArray)?.count == 3 )
        
        // keep nil keys
        XCTAssert((nest?.keys().contains("none"))!)
        XCTAssert((nest!["none"] as? NSNull) == Flask.Null)
    }
    
}
