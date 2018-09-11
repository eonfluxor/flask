//
//  States.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

struct AnyStates:States {
    
}

public protocol States : Codable {
    init() //construct at initial states
    func toDictionary()->LabDictType
    func toJsonDictionary()->[String:Any]
}


public extension States{
    
//    var dictionary: [String: Any] {
//        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
//    }
    
    
    func toDictionary()->LabDictType{
//        let dict = self.dictionary
        var result:LabDictType = [:]
        
        let mirror = Mirror(reflecting: self)
        
        for (label, value) in mirror.children {
            guard let label = label else {
                continue
            }
            
            if SubstanceConcrete.isInternalProp(label) {
                continue
            }
            
            result[label] = Lab.Nil
            result[label] = value as? AnyHashable
            
            if(SubstanceSerializer.isDictionaryRef(value)){
                let nestedRef = SubstanceSerializer.nestDictionaries(namespace: label,
                                                                root: LabDictRef(result as NSDictionary),
                                                                children: value as! LabDictRef)
                result = nestedRef.dictionary as! LabDictType
            }
        }
        
        
        
        return result
        
    }
    
    func toJsonDictionary()->[String:Any]{
        
        var result:[String:Any] = [:]
        
        let mirror = Mirror(reflecting: self)
        
        for (label, value) in mirror.children {
            guard let label = label else {
                continue
            }
            
            if SubstanceConcrete.isInternalProp(label) {
                continue
            }
            
            if SubstanceConcrete.isObjectRef(value) {
                continue
            }
            
            if(SubstanceSerializer.isDictionaryRef(value)){
                let nest =  SubstanceSerializer.flattenDictionary(value as! LabDictRef)
                 result[label] = nest
            } else{
                 result[label] = value
            }
        }
        
        return result
    }
   
    
}

