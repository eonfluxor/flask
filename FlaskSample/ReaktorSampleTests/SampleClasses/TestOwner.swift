//
//  TestOwner.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/3/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif
import XCTest

import Flask

class TestOwner: NSObject {

    func reactionMethod(_ expectation:XCTestExpectation){
        expectation.fulfill()
    }
}
