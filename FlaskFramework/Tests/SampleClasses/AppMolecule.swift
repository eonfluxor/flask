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

struct Atoms : MoleculeAtoms {
   
    enum atom : AtomName{
        case counter, text, map, object
    }
    
    var counter = 0
    var text = ""
    var object:LabRef?
    var map:LabDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

class App : Molecule<Atoms,Mixers> {
    
    override func bindMixers(){
        
        mix(.Count) {[weak self] (payload, commit, abort)  in
            self?.atoms.counter = (self?.atoms.counter)! + 1
            commit()
        }
        
        mix(.Text) {[weak self] (payload, commit, abort)  in
            self?.atoms.text = "mixd"
            commit()
        }
    }
    
}

