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

    
    var store:MoleculeConcrete
    var changes:FlaskStateDictionaryType
    
    required public init(_ store:MoleculeConcrete){
        self.store = store
        self.changes = FlaskReaction.reduceChanges(store: self.store)
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
        
        var change = FlaskReaction.change(store, key)
        change._store = store
        closure(change)
    }
    
    
    public func at(_ aMolecule:MoleculeConcrete)->FlaskReaction?{
       
        if store !== aMolecule{
            return .none
        }
        return self
    }
    
    func assertKey(_ key:String){
        
        let error = {
            fatalError("the key `\(key)` is not defined in state")
            
        }
        let state = store.lastStateDictionary()
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
    
    static public func reduceChanges(store:MoleculeConcrete)->FlaskStateDictionaryType{
    
        let oldState = store.lastStateDictionary()
        let newState = store.stateDictionary()
        
        return reduceChanges(oldState,newState)
    }
    
    static public func reduceChanges(_ oldState:FlaskStateDictionaryType, _ newState:FlaskStateDictionaryType)->FlaskStateDictionaryType{
        
        var changes:FlaskStateDictionaryType=[:]
        
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
    
    static public func change(_ store:MoleculeConcrete, _ key: String) -> FlaskChangeTemplate {
        
        let oldState = store.lastStateDictionary()
        let newState = store.stateDictionary()
        
        return change(oldState,newState,key)
    }
    

    static public func change(_ oldState:FlaskStateDictionaryType,_ newState:FlaskStateDictionaryType, _ key: String) -> FlaskChangeTemplate {
        
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
