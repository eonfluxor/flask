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

    
    weak public var onPause:MixerPause?
    private(set) var store:StoreConcrete
    private(set) var changes:LabDictType
    
    required public init(_ store:StoreConcrete){
        self.store = store
        self.changes = FlaskReaction.reduceChanges(store: self.store)
    }
    
    public func changed()->Bool{
        return changes.count > 0
    }
    
    public func on<T:RawRepresentable>(_ key:T,_ closure:ChangeClosure){
        on(key.rawValue as! String, closure)
    }
    
    public func on(_ key:String,_ closure:ChangeClosure){
        
        
        assertKey(key)
        
        guard changes[key] != nil else {
            return
        }
        
        var change = FlaskReaction.change(store, key)
        change._store = store
        closure(change)
    }
    
    
    public func at(_ aStore:StoreConcrete)->FlaskReaction?{
       
        if store !== aStore{
            return .none
        }
        return self
    }
    
    func assertKey(_ key:String){
        
        let error = {
            fatalError("the key `\(key)` is not defined in state")
            
        }
        let state = store.stateSnapshotDictionary()
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
    
    static public func reduceChanges(store:StoreConcrete)->LabDictType{
    
        let oldState = store.stateSnapshotDictionary()
        let newState = store.stateDictionary()
        
        return reduceChanges(oldState,newState)
    }
    
    static public func reduceChanges(_ oldState:LabDictType, _ newState:LabDictType)->LabDictType{
        
        var changes:LabDictType=[:]
        
        let uniqueKeys = Set(Array(oldState.keys) + Array(newState.keys))
        
        for key in uniqueKeys {
            
            let change = FlaskReaction.change(oldState, newState, key)
            
            if change.mixd()  {
                //use casting to ensure nil is passed
                changes[key] = change.newValue() as AnyHashable?
            }

        }
        return changes
        
    }
    
    static public func change(_ store:StoreConcrete, _ key: String) -> StoreChange {
        
        let oldState = store.stateSnapshotDictionary()
        let newState = store.stateDictionary()
        
        return change(oldState,newState,key)
    }
    

    static public func change(_ oldState:LabDictType,_ newState:LabDictType, _ key: String) -> StoreChange {
        
        var oldValue:AnyHashable? = Lab.Nil
        var newValue:AnyHashable? = Lab.Nil
        
        if let val = oldState[key] {
            oldValue = val
        }
        
        if let val = newState[key] {
            newValue = val
        }
        
    
        var change = StoreChange()
        change.setOldValue(oldValue)
        change.setNewValue(newValue)
        change._key = key
        
        return change
    }

   
}
