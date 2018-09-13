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

    
    weak public var onLock:FluxLock?
    private(set) var substance:SubstanceConcrete
    private(set) var changes:FlaskDictType
    
    required public init(_ substance:SubstanceConcrete){
        self.substance = substance
        self.changes = FlaskReaction.reduceChanges(substance: self.substance)
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
        
        var change = FlaskReaction.change(substance, key)
        change._substance = substance
        closure(change)
    }
    
    
    public func at(_ aSubstance:SubstanceConcrete)->FlaskReaction?{
       
        if substance !== aSubstance{
            return .none
        }
        return self
    }
    
    func assertKey(_ key:String){
        
        let error = {
            fatalError("the key `\(key)` is not defined in state")
            
        }
        let state = substance.stateSnapshotDictionary()
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
    
    static public func reduceChanges(substance:SubstanceConcrete)->FlaskDictType{
    
        let oldState = substance.stateSnapshotDictionary()
        let newState = substance.stateDictionary()
        
        return reduceChanges(oldState,newState)
    }
    
    static public func reduceChanges(_ oldState:FlaskDictType, _ newState:FlaskDictType)->FlaskDictType{
        
        var changes:FlaskDictType=[:]
        
        let uniqueKeys = Set(Array(oldState.keys) + Array(newState.keys))
        
        for key in uniqueKeys {
            
            let change = FlaskReaction.change(oldState, newState, key)
            
            if change.mutationd()  {
                //use casting to ensure nil is passed
                changes[key] = change.newValue() as AnyHashable?
            }

        }
        return changes
        
    }
    
    static public func change(_ substance:SubstanceConcrete, _ key: String) -> SubstanceChange {
        
        let oldState = substance.stateSnapshotDictionary()
        let newState = substance.stateDictionary()
        
        return change(oldState,newState,key)
    }
    

    static public func change(_ oldState:FlaskDictType,_ newState:FlaskDictType, _ key: String) -> SubstanceChange {
        
        var oldValue:AnyHashable? = Flask.Nil
        var newValue:AnyHashable? = Flask.Nil
        
        if let val = oldState[key] {
            oldValue = val
        }
        
        if let val = newState[key] {
            newValue = val
        }
        
    
        var change = SubstanceChange()
        change.setOldValue(oldValue)
        change.setNewValue(newValue)
        change._key = key
        
        return change
    }

   
}
