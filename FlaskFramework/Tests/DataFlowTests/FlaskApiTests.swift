//
//  InitializerTests.swift
//  Flask-iOS
//
//  Created by hassan uriostegui on 9/11/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

import XCTest

class InitializerTests: XCTestCase, FlaskReactor  {
    
    var expecation:XCTestExpectation?
    var expecation2:XCTestExpectation?
    var substance:ReactiveSubstance? = App()
    
    func flaskReactor( reaction:FlaskReaction) {
        reaction.on(AppState.prop.counter) { (change) in
            expecation?.fulfill()
        }
        reaction.on(AppState.prop.text) { (change) in
            expecation2?.fulfill()
        }
    }
    
    override func setUp() {
        substance!.name(as:"chain tests")
        AttachFlaskReactor(to:self, mixing:[substance!])
        expecation = self.expectation(description: "callback on counter")
        expecation2 = self.expectation(description: "callback on text")
        
    }
    override func tearDown(){
        //it needs to explictely detached because the test keeps owner isntance reference alive after this
        DetachFlaskReactor(from: self)
        substance = nil
    }
    
    func testFlaskAPI(){
        
        UseFlaskReactor(at:self)
            .toMix(self.substance!) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance!) { (substance) in
                substance.prop.text = "text"
            }.andReact()
        
        waitForExpectations(timeout: 2, handler: nil)
      
    }
    
}
