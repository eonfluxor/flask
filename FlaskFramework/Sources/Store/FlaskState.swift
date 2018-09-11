//
//  MoleculeAtom.swift
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

struct AnyMoleculeAtom:MoleculeAtom {
    
}

public protocol MoleculeAtom : Codable {
    init() //construct at initial atoms
    func toDictionary()->LabDictionaryType
    func toJsonDictionary()->[String:Any]
}


public extension MoleculeAtom{
    
//    var dictionary: [String: Any] {
//        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
//    }
    
    
    func toDictionary()->LabDictionaryType{
//        let dict = self.dictionary
        var result:LabDictionaryType = [:]
        
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
            
            if(LabSerializer.isDictionaryRef(value)){
                let nestedRef = LabSerializer.nestDictionaries(namespace: label,
                                                                root: LabDictionaryRef(result as NSDictionary),
                                                                children: value as! LabDictionaryRef)
                result = nestedRef.dictionary as! LabDictionaryType
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
            
            if(LabSerializer.isDictionaryRef(value)){
                let nest =  LabSerializer.flattenDictionary(value as! LabDictionaryRef)
                 result[label] = nest
            } else{
                 result[label] = value
            }
        }
        
        return result
    }
   
    
}

