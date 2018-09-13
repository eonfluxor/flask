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
    
    func flaskReactor(attachedTo: AnyObject, reaction: FlaskReaction) {
        reaction.on(AppState.named.counter) { (change) in
            
        }
        reaction.on(AppState.named.text) { (change) in
            
        }
    }
    
    override func setUp() {
         FlaskAttach(to:self, mixing:[Substances.app])
    }
    
    func testOwnerInit(){
        
        FlaskUse(self)
        FlaskDetach(from: self)
        
//        UseFlask(self).toMutate(Substances.app) { (substance) in
//            substance.state.counter = 10
//            }.andMutate(Substances.app) { (substance) in
//                substance.state.text = "text"
//            }.andReact()
        
    }
    
}
