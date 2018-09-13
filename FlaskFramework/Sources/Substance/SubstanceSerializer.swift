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
    
    static public func flattenDictionary(_ dict:FlaskDictRef) -> [String:Any]{
        
        var result:[String:Any] = [:]
        
        let keys = dict.keys()
        
        for key in keys {
            
            let value = dict[key]
            
            if(isDictionaryRef(value)){
                //recursion
                let nest = flattenDictionary(value as! FlaskDictRef)
                result[key] = nest
            } else{
                result[key] = value
            }
            
        }
        
        return result
        
    }
    
    static public func nestDictionaries( namespace:String,  root:FlaskDictRef,  children:FlaskDictRef) -> FlaskDictRef{
        
        var result = FlaskDictRef(root.dictionary)
        
        let keys = children.keys()
        
        for key in keys {
            
            let value = children[key]
            let childKey = "\(namespace).\(key)"
            assert( isNilFlask(result[childKey]) , "namespace collision!" )
            
            result[childKey] = value
            
            if(SubstanceSerializer.isDictionaryRef(value)){
                //recursion
                result = SubstanceSerializer.nestDictionaries(namespace: childKey,
                                                         root: result,
                                                         children: value as! FlaskDictRef)
            }
            
        }
        
        return result
        
    }
    
    
    static public func isDictionaryRef(_ value:Any?)->Bool{
        return ((value as? FlaskDictRef) != nil)
    }
    
}
