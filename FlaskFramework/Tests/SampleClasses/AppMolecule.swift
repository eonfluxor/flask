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


enum AppMixers : MixerName {
    case Count
    case Text
    case Object
}

struct AppAtoms : Atoms {
   
    enum named : AtomName{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:LabRef?
    var map:LabDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : Substance<AppAtoms,AppMixers> {
    
    override func defineMixers(){
        
        mixer(.Count) {[weak self] (payload, react, abort)  in
            self?.atoms.counter = (self?.atoms.counter)! + 1
            react()
        }
        
        mixer(.Text) {[weak self] (payload, react, abort)  in
            self?.atoms.text = "mixd"
            react()
        }
    }
    
}

