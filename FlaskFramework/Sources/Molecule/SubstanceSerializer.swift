//
//  SubstanceSerializer.swift
//  Reaktor
//
//  Created by hassan uriostegui on 9/10/18.
//  Copyright © 2018 Eonflux - Hassan Uriostegui. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public struct SubstanceSerializer{
    
    static public func jsonFromStates<K:States>(_ states:K) throws ->String {
        
        let jsonData = try JSONEncoder().encode(states)
        
        return String(data: jsonData, encoding: .utf8)!
        
    }
    
    static public func statesFromJson<K:States>(_ json:String) throws ->K {
        
        let jsonData = json.data(using: .utf8)!
        return try statesFromData(jsonData)
    }
    
    
    static public func dataFromState<K:States>(_ states:K) throws ->Data? {
        
        let json = try jsonFromStates(states)
        return json.data(using: .utf16)
    }
    
    static public func statesFromData<K:States>(_ jsonData:Data) throws ->K {
        
        let states:K = try! JSONDecoder().decode(K.self, from: jsonData)
        return states
    }
    
    static public func flattenDictionary(_ dict:LabDictRef) -> [String:Any]{
        
        var result:[String:Any] = [:]
        
        let keys = dict.keys()
        
        for key in keys {
            
            let value = dict[key]
            
            if(isDictionaryRef(value)){
                //recursion
                let nest = flattenDictionary(value as! LabDictRef)
                result[key] = nest
            } else{
                result[key] = value
            }
            
        }
        
        return result
        
    }
    
    static public func nestDictionaries( namespace:String,  root:LabDictRef,  children:LabDictRef) -> LabDictRef{
        
        var result = LabDictRef(root.dictionary)
        
        let keys = children.keys()
        
        for key in keys {
            
            let value = children[key]
            let childKey = "\(namespace).\(key)"
            assert( isLabNil(result[childKey]) , "namespace collision!" )
            
            result[childKey] = value
            
            if(SubstanceSerializer.isDictionaryRef(value)){
                //recursion
                result = SubstanceSerializer.nestDictionaries(namespace: childKey,
                                                         root: result,
                                                         children: value as! LabDictRef)
            }
            
        }
        
        return result
        
    }
    
    
    static public func isDictionaryRef(_ value:Any?)->Bool{
        return ((value as? LabDictRef) != nil)
    }
    
}
