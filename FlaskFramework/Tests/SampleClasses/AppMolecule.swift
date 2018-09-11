//
//  Store.swift
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


enum AppEvents : BusEvent {
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
    var object:FluxRef?
    var map:FluxDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : Store<AppState,AppEvents> {
    
    override func defineBus(){
        
        on(.Count) {[weak self] (payload, react, abort)  in
            self?.state.counter = (self?.state.counter)! + 1
            react()
        }
        
        on(.Text) {[weak self] (payload, react, abort)  in
            self?.state.text = "mixd"
            react()
        }
    }
    
}

