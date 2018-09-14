//
//  Substance.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

import Flask

enum Mixers : FluxMixer {
    case Count
    case Text
    case Object
}

struct AppState : State {
   
    enum prop : StateProp{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:FlaskNSRef?
    var map:FlaskDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : ReactiveSubstance<AppState,Mixers> {
    
    override func defineMixers(){
        
        define(mix: .Count) { (payload, react, abort)  in
            self.prop.counter = self.prop.counter + 1
            react()
        }
        
        define(mix: .Text) { (payload, react, abort)  in
            self.prop.text = "mixed"
            react()
        }
    }
    
}

class Feed : Substance<AppState> {}

