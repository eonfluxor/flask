//
//  Molecule.swift
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


enum Actions : FlaskActions {
    case Count
    case Text
    case Object
}

struct State : FlaskState {
   
    enum prop : FlaskProps{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:FlaskRef?
    var map:FlaskDictionaryRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : Molecule<Actions,State> {
    
    override func bindActions(){
        
        mutator(.Count) {[weak self] (payload, commit, abort)  in
            self?.state.counter = (self?.state.counter)! + 1
            commit()
        }
        
        mutator(.Text) {[weak self] (payload, commit, abort)  in
            self?.state.text = "mutated"
            commit()
        }
    }
    
}

