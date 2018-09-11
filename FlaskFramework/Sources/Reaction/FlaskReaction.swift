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
    var changes:MoleculeStateDictionaryType
    
    required public init(_ molecule:MoleculeConcrete){
        self.molecule = molecule
        self.changes = FlaskReaction.reduceChanges(molecule: self.molecule)
    }
    
    public func changed()->Bool{
        return changes.count > 0
    }
    
    public func on<T:RawRepresentable>(_ key:T,_ closure:FlaskReactionClosure){
        on(key.rawValue as! String, closure)
    }
    
    public func on(_ key:String,_ closure:FlaskReactionClosure){
        
        
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
            fatalError("the key `\(key)` is not defined in state")
            
        }
        let state = molecule.lastStateDictionary()
        let rootKey = key.split(separator: ".").first
        
        guard (rootKey != nil) else{
            error()
        }
        
        guard state.keys.contains(String(rootKey!)) else{
            error()
        }
        
    }
    
}

public extension FlaskReaction {
    
    static public func reduceChanges(molecule:MoleculeConcrete)->MoleculeStateDictionaryType{
    
        let oldState = molecule.lastStateDictionary()
        let newState = molecule.stateDictionary()
        
        return reduceChanges(oldState,newState)
    }
    
    static public func reduceChanges(_ oldState:MoleculeStateDictionaryType, _ newState:MoleculeStateDictionaryType)->MoleculeStateDictionaryType{
        
        var changes:MoleculeStateDictionaryType=[:]
        
        let uniqueKeys = Set(Array(oldState.keys) + Array(newState.keys))
        
        for key in uniqueKeys {
            
            let change = FlaskReaction.change(oldState, newState, key)
            
            if change.mutated()  {
                //use casting to ensure nil is passed
                changes[key] = change.newValue() as AnyHashable?
            }

        }
        return changes
        
    }
    
    static public func change(_ molecule:MoleculeConcrete, _ key: String) -> FlaskChangeTemplate {
        
        let oldState = molecule.lastStateDictionary()
        let newState = molecule.stateDictionary()
        
        return change(oldState,newState,key)
    }
    

    static public func change(_ oldState:MoleculeStateDictionaryType,_ newState:MoleculeStateDictionaryType, _ key: String) -> FlaskChangeTemplate {
        
        var oldValue:AnyHashable? = Lab.Nil
        var newValue:AnyHashable? = Lab.Nil
        
        if let val = oldState[key] {
            oldValue = val
        }
        
        if let val = newState[key] {
            newValue = val
        }
        
    
        var change = FlaskChangeTemplate()
        change.setOldValue(oldValue)
        change.setNewValue(newValue)
        change._key = key
        
        return change
    }

   
}
