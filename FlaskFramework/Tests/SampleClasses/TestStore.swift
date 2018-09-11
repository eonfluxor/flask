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


enum Actions : FluxActions {
    case Count
    case Text
    case Object
}

struct State : FluxState {
   
    enum prop : FluxProps{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:FluxRef?
    var map:FluxDictionaryRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class Store : FluxStore<Actions,State> {
    
    override func bindActions(){
        
        action(.Count) {[weak self] (payload, commit, abort)  in
            self?.state.counter = (self?.state.counter)! + 1
            commit()
        }
        
        action(.Text) {[weak self] (payload, commit, abort)  in
            self?.state.text = "mutated"
            commit()
        }
    }
    
}

