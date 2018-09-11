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


enum Mixers : MoleculeMixers {
    case Count
    case Text
    case Object
}

struct State : MoleculeState {
   
    enum atom : Atoms{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:FlaskRef?
    var map:FlaskDictionaryRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : Molecule<State,Mixers> {
    
    override func bindMixers(){
        
        mixer(.Count) {[weak self] (payload, commit, abort)  in
            self?.state.counter = (self?.state.counter)! + 1
            commit()
        }
        
        mixer(.Text) {[weak self] (payload, commit, abort)  in
            self?.state.text = "mixd"
            commit()
        }
    }
    
}

