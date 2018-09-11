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



public class FluxReaction {

    
    var store:FluxStoreConcrete
    var changes:FluxStateDictionaryType
    
    required public init(_ store:FluxStoreConcrete){
        self.store = store
        self.changes = FluxReaction.reduceChanges(store: self.store)
    }
    
    public func changed()->Bool{
        return changes.count > 0
    }
    
    public func on<T:RawRepresentable>(_ key:T,_ closure:FluxReactionClosure){
        on(key.rawValue as! String, closure)
    }
    
    public func on(_ key:String,_ closure:FluxReactionClosure){
        
        
        assertKey(key)
        
        guard changes[key] != nil else {
            return
        }
        
        var change = FluxReaction.change(store, key)
        change._store = store
        closure(change)
    }
    
    
    public func at(_ aStore:FluxStoreConcrete)->FluxReaction?{
       
        if store !== aStore{
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

public extension FluxReaction {
    
    static public func reduceChanges(store:FluxStoreConcrete)->FluxStateDictionaryType{
    
        let oldState = store.lastStateDictionary()
        let newState = store.stateDictionary()
        
        return reduceChanges(oldState,newState)
    }
    
    static public func reduceChanges(_ oldState:FluxStateDictionaryType, _ newState:FluxStateDictionaryType)->FluxStateDictionaryType{
        
        var changes:FluxStateDictionaryType=[:]
        
        let uniqueKeys = Set(Array(oldState.keys) + Array(newState.keys))
        
        for key in uniqueKeys {
            
            let change = FluxReaction.change(oldState, newState, key)
            
            if change.mutated()  {
                //use casting to ensure nil is passed
                changes[key] = change.newValue() as AnyHashable?
            }

        }
        return changes
        
    }
    
    static public func change(_ store:FluxStoreConcrete, _ key: String) -> FluxChangeTemplate {
        
        let oldState = store.lastStateDictionary()
        let newState = store.stateDictionary()
        
        return change(oldState,newState,key)
    }
    

    static public func change(_ oldState:FluxStateDictionaryType,_ newState:FluxStateDictionaryType, _ key: String) -> FluxChangeTemplate {
        
        var oldValue:AnyHashable? = Flux.Nil
        var newValue:AnyHashable? = Flux.Nil
        
        if let val = oldState[key] {
            oldValue = val
        }
        
        if let val = newState[key] {
            newValue = val
        }
        
    
        var change = FluxChangeTemplate()
        change.setOldValue(oldValue)
        change.setNewValue(newValue)
        change._key = key
        
        return change
    }

   
}
