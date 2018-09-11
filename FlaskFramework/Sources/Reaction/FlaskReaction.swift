//
//  FLUXChanges.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 8/28/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif



public class FlaskReaction {

    
    var molecule:MoleculeConcrete
    var changes:LabDictType
    
    required public init(_ molecule:MoleculeConcrete){
        self.molecule = molecule
        self.changes = FlaskReaction.reduceChanges(molecule: self.molecule)
    }
    
    public func changed()->Bool{
        return changes.count > 0
    }
    
    public func on<T:RawRepresentable>(_ key:T,_ closure:FlaskClosure){
        on(key.rawValue as! String, closure)
    }
    
    public func on(_ key:String,_ closure:FlaskClosure){
        
        
        assertKey(key)
        
        guard changes[key] != nil else {
            return
        }
        
        var change = FlaskReaction.change(molecule, key)
        change._molecule = molecule
        closure(change)
    }
    
    
    public func at(_ aMolecule:MoleculeConcrete)->FlaskReaction?{
       
        if molecule !== aMolecule{
            return .none
        }
        return self
    }
    
    func assertKey(_ key:String){
        
        let error = {
            fatalError("the key `\(key)` is not defined in atoms")
            
        }
        let atoms = molecule.lastAtomDictionary()
        let rootKey = key.split(separator: ".").first
        
        guard (rootKey != nil) else{
            error()
        }
        
        guard atoms.keys.contains(String(rootKey!)) else{
            error()
        }
        
    }
    
}

public extension FlaskReaction {
    
    static public func reduceChanges(molecule:MoleculeConcrete)->LabDictType{
    
        let oldAtom = molecule.lastAtomDictionary()
        let newAtom = molecule.atomsDictionary()
        
        return reduceChanges(oldAtom,newAtom)
    }
    
    static public func reduceChanges(_ oldAtom:LabDictType, _ newAtom:LabDictType)->LabDictType{
        
        var changes:LabDictType=[:]
        
        let uniqueKeys = Set(Array(oldAtom.keys) + Array(newAtom.keys))
        
        for key in uniqueKeys {
            
            let change = FlaskReaction.change(oldAtom, newAtom, key)
            
            if change.mixd()  {
                //use casting to ensure nil is passed
                changes[key] = change.newValue() as AnyHashable?
            }

        }
        return changes
        
    }
    
    static public func change(_ molecule:MoleculeConcrete, _ key: String) -> MoleculeChange {
        
        let oldAtom = molecule.lastAtomDictionary()
        let newAtom = molecule.atomsDictionary()
        
        return change(oldAtom,newAtom,key)
    }
    

    static public func change(_ oldAtom:LabDictType,_ newAtom:LabDictType, _ key: String) -> MoleculeChange {
        
        var oldValue:AnyHashable? = Lab.Nil
        var newValue:AnyHashable? = Lab.Nil
        
        if let val = oldAtom[key] {
            oldValue = val
        }
        
        if let val = newAtom[key] {
            newValue = val
        }
        
    
        var change = MoleculeChange()
        change.setOldValue(oldValue)
        change.setNewValue(newValue)
        change._key = key
        
        return change
    }

   
}
