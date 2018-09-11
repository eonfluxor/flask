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

    
    weak public var labPause:MixerPause?
    private(set) var substance:SubstanceConcrete
    private(set) var changes:LabDictType
    
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
            fatalError("the key `\(key)` is not defined in atoms")
            
        }
        let atoms = substance.atomsSnapshotDictionary()
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
    
    static public func reduceChanges(substance:SubstanceConcrete)->LabDictType{
    
        let oldAtom = substance.atomsSnapshotDictionary()
        let newAtom = substance.atomsDictionary()
        
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
    
    static public func change(_ substance:SubstanceConcrete, _ key: String) -> SubstanceChange {
        
        let oldAtom = substance.atomsSnapshotDictionary()
        let newAtom = substance.atomsDictionary()
        
        return change(oldAtom,newAtom,key)
    }
    

    static public func change(_ oldAtom:LabDictType,_ newAtom:LabDictType, _ key: String) -> SubstanceChange {
        
        var oldValue:AnyHashable? = Lab.Nil
        var newValue:AnyHashable? = Lab.Nil
        
        if let val = oldAtom[key] {
            oldValue = val
        }
        
        if let val = newAtom[key] {
            newValue = val
        }
        
    
        var change = SubstanceChange()
        change.setOldValue(oldValue)
        change.setNewValue(newValue)
        change._key = key
        
        return change
    }

   
}
