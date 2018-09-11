//
//  MoleculeState.swift
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

struct AnyMoleculeState:MoleculeState {
    
}

public protocol MoleculeState : Codable {
    init() //construct at initial state
    func toDictionary()->MoleculeStateDictionaryType
    func toJsonDictionary()->[String:Any]
}


public extension MoleculeState{
    
//    var dictionary: [String: Any] {
//        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
//    }
    
    
    func toDictionary()->MoleculeStateDictionaryType{
//        let dict = self.dictionary
        var result:MoleculeStateDictionaryType = [:]
        
        let mirror = Mirror(reflecting: self)
        
        for (label, value) in mirror.children {
            guard let label = label else {
                continue
            }
            
            if MoleculeConcrete.isInternalProp(label) {
                continue
            }
            
            result[label] = Lab.Nil
            result[label] = value as? AnyHashable
            
            if(FlaskSerializer.isDictionaryRef(value)){
                let nestedRef = FlaskSerializer.nestDictionaries(namespace: label,
                                                                root: FlaskDictionaryRef(result as NSDictionary),
                                                                children: value as! FlaskDictionaryRef)
                result = nestedRef.dictionary as! MoleculeStateDictionaryType
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
            
            if MoleculeConcrete.isInternalProp(label) {
                continue
            }
            
            if MoleculeConcrete.isObjectRef(value) {
                continue
            }
            
            if(FlaskSerializer.isDictionaryRef(value)){
                let nest =  FlaskSerializer.flattenDictionary(value as! FlaskDictionaryRef)
                 result[label] = nest
            } else{
                 result[label] = value
            }
        }
        
        return result
    }
   
    
}

