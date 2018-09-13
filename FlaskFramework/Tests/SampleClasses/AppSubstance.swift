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


enum Mixers : FluxMixer {
    case Count
    case Text
    case Object
}

enum Mixers2 : FluxMixer {
    case Count
    case Text
    case Object
}

struct AppState : State {
   
    enum named : StateName{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:FlaskNSRef?
    var map:FlaskDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : Substance<AppState,Mixers> {
    
    override func defineMixers(){
        
        define(mix: .Count) { (payload, react, abort)  in
            self.stateMix.counter = self.stateMix.counter + 1
            react()
        }
        
        define(mix: .Text) { (payload, react, abort)  in
            self.stateMix.text = "mixed"
            react()
        }
    }
    
}

