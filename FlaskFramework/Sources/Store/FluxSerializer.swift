//
//  FluxSerializer.swift
//  Reaktor
//
//  Created by hassan uriostegui on 9/10/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public struct FluxSerializer{
    
    static public func jsonFromState<K:FluxState>(_ state:K) throws ->String {
        
        let jsonData = try JSONEncoder().encode(state)
        
        return String(data: jsonData, encoding: .utf8)!
        
    }
    
    static public func stateFromJson<K:FluxState>(_ json:String) throws ->K {
        
        let jsonData = json.data(using: .utf8)!
        return try stateFromData(jsonData)
    }
    
    
    static public func dataFromState<K:FluxState>(_ state:K) throws ->Data? {
        
        let json = try jsonFromState(state)
        return json.data(using: .utf16)
    }
    
    static public func stateFromData<K:FluxState>(_ jsonData:Data) throws ->K {
        
        let state:K = try! JSONDecoder().decode(K.self, from: jsonData)
        return state
    }
    
    static public func flattenDictionary(_ dict:FluxDictionaryRef) -> [String:Any]{
        
        var result:[String:Any] = [:]
        
        let keys = dict.keys()
        
        for key in keys {
            
            let value = dict[key]
            
            if(isDictionaryRef(value)){
                //recursion
                let nest = flattenDictionary(value as! FluxDictionaryRef)
                result[key] = nest
            } else{
                result[key] = value
            }
            
        }
        
        return result
        
    }
    
    static public func nestDictionaries( namespace:String,  root:FluxDictionaryRef,  children:FluxDictionaryRef) -> FluxDictionaryRef{
        
        var result = FluxDictionaryRef(root.dictionary)
        
        let keys = children.keys()
        
        for key in keys {
            
            let value = children[key]
            let childKey = "\(namespace).\(key)"
            assert( isFluxNil(result[childKey]) , "namespace collision!" )
            
            result[childKey] = value
            
            if(FluxSerializer.isDictionaryRef(value)){
                //recursion
                result = FluxSerializer.nestDictionaries(namespace: childKey,
                                                         root: result,
                                                         children: value as! FluxDictionaryRef)
            }
            
        }
        
        return result
        
    }
    
    
    static public func isDictionaryRef(_ value:Any?)->Bool{
        return ((value as? FluxDictionaryRef) != nil)
    }
    
}
