//
//  FluxState.swift
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

struct AnyFluxState:FluxState {
    
}

public protocol FluxState : Codable {
    init() //construct at initial state
    func toDictionary()->FluxStateDictionaryType
    func toJsonDictionary()->[String:Any]
}


public extension FluxState{
    
//    var dictionary: [String: Any] {
//        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
//    }
    
    
    func toDictionary()->FluxStateDictionaryType{
//        let dict = self.dictionary
        var result:FluxStateDictionaryType = [:]
        
        let mirror = Mirror(reflecting: self)
        
        for (label, value) in mirror.children {
            guard let label = label else {
                continue
            }
            
            if FluxStoreConcrete.isInternalProp(label) {
                continue
            }
            
            result[label] = Flux.Nil
            result[label] = value as? AnyHashable
            
            if(FluxSerializer.isDictionaryRef(value)){
                let nestedRef = FluxSerializer.nestDictionaries(namespace: label,
                                                                root: FluxDictionaryRef(result as NSDictionary),
                                                                children: value as! FluxDictionaryRef)
                result = nestedRef.dictionary as! FluxStateDictionaryType
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
            
            if FluxStoreConcrete.isInternalProp(label) {
                continue
            }
            
            if FluxStoreConcrete.isObjectRef(value) {
                continue
            }
            
            if(FluxSerializer.isDictionaryRef(value)){
                let nest =  FluxSerializer.flattenDictionary(value as! FluxDictionaryRef)
                 result[label] = nest
            } else{
                 result[label] = value
            }
        }
        
        return result
    }
    
    
    
    
   
    
    
    
    
}

