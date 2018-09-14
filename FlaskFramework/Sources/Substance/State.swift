//
//  State.swift
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



public protocol State : Codable {
    init() //construct at initial state
    func toDictionary()->FlaskDictType
    func toJsonDictionary()->[String:Any]
}


public extension State{
    
//    var dictionary: [String: Any] {
//        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
//    }
    
    
    func toDictionary()->FlaskDictType{
//        let dict = self.dictionary
        var result:FlaskDictType = [:]
        
        let mirror = Mirror(reflecting: self)
        
        for (label, value) in mirror.children {
            guard let label = label else {
                continue
            }
            
            if SubstanceConcrete.isInternalProp(label) {
                continue
            }
            
            result[label] = Flask.Nil
            result[label] = value as? AnyHashable
            
            if(SubstanceSerializer.isDictionaryRef(value)){
                let nestedRef = SubstanceSerializer.nestDictionaries(namespace: label,
                                                                root: FlaskDictRef(result as NSDictionary),
                                                                children: value as! FlaskDictRef)
                result = nestedRef.dictionary as! FlaskDictType
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
                let nest =  SubstanceSerializer.flattenDictionary(value as! FlaskDictRef)
                 result[label] = nest
            } else{
                 result[label] = value
            }
        }
        
        return result
    }
   
    
}

