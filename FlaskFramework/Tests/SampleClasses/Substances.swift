//
//  Substances.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

struct FeedSate : State {
    var feed = FlaskDictRef()
}

struct Substances  {
  static let app = App()
  static let feed = Flask.newSubstance(definedBy: FeedSate.self)
}
