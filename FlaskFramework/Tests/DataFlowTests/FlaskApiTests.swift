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
    var substance:Substance? = App()
    
    func flaskReactor(attachedTo: AnyObject, reaction: FlaskReaction) {
        reaction.on(AppState.named.counter) { (change) in
            expecation?.fulfill()
        }
        reaction.on(AppState.named.text) { (change) in
            expecation2?.fulfill()
        }
    }
    
    override func setUp() {
        substance!.name(as:"chain tests")
        AttachFlaskReactor(to:self, mixing:[substance!])
        expecation = self.expectation(description: "callbac on counter")
        expecation2 = self.expectation(description: "callbac on text")
        
    }
    override func tearDown(){
        DetachFlaskReactor(from: self)
        substance = nil
    }
    
    func testOwnerInit(){
        
        UseFlaskReactor(at:self)
            .toMix(self.substance!) { (substance) in
                substance.state.counter = 10
            }.andMix(self.substance!) { (substance) in
                substance.state.text = "text"
            }.andReact()
        
        waitForExpectations(timeout: 2, handler: nil)
      
    }
    
}
