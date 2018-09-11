//
//  StoreSerializer.swift
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

public struct StoreSerializer{
    
    static public func jsonFromState<K:State>(_ state:K) throws ->String {
        
        let jsonData = try JSONEncoder().encode(state)
        
        return String(data: jsonData, encoding: .utf8)!
        
    }
    
    static public func stateFromJson<K:State>(_ json:String) throws ->K {
        
        let jsonData = json.data(using: .utf8)!
        return try stateFromData(jsonData)
    }
    
    
    static public func dataFromState<K:State>(_ state:K) throws ->Data? {
        
        let json = try jsonFromState(state)
        return json.data(using: .utf16)
    }
    
    static public func stateFromData<K:State>(_ jsonData:Data) throws ->K {
        
        let state:K = try! JSONDecoder().decode(K.self, from: jsonData)
        return state
    }
    
    static public func flattenDictionary(_ dict:FluxDictRef) -> [String:Any]{
        
        var result:[String:Any] = [:]
        
        let keys = dict.keys()
        
        for key in keys {
            
            let value = dict[key]
            
            if(isDictionaryRef(value)){
                //recursion
                let nest = flattenDictionary(value as! FluxDictRef)
                result[key] = nest
            } else{
                result[key] = value
            }
            
        }
        
        return result
        
    }
    
    static public func nestDictionaries( namespace:String,  root:FluxDictRef,  children:FluxDictRef) -> FluxDictRef{
        
        var result = FluxDictRef(root.dictionary)
        
        let keys = children.keys()
        
        for key in keys {
            
            let value = children[key]
            let childKey = "\(namespace).\(key)"
            assert( isFluxNil(result[childKey]) , "namespace collision!" )
            
            result[childKey] = value
            
            if(StoreSerializer.isDictionaryRef(value)){
                //recursion
                result = StoreSerializer.nestDictionaries(namespace: childKey,
                                                         root: result,
                                                         children: value as! FluxDictRef)
            }
            
        }
        
        return result
        
    }
    
    
    static public func isDictionaryRef(_ value:Any?)->Bool{
        return ((value as? FluxDictRef) != nil)
    }
    
}
