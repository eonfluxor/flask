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

class InitializerTests: XCTestCase {
    class ViewController: UIViewController, FlaskOwner {
        
    }
    
    func testOwnerInit(){
        let vc = ViewController()
        
    }
    
}
