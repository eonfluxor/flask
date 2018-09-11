//
//  MoleculeSerializer.swift
//  Reaktor
//
//  Created by hassan uriostegui on 9/10/18.
//  Copyright © 2018 eonflask. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public struct MoleculeSerializer{
    
    static public func jsonFromAtoms<K:Atoms>(_ atoms:K) throws ->String {
        
        let jsonData = try JSONEncoder().encode(atoms)
        
        return String(data: jsonData, encoding: .utf8)!
        
    }
    
    static public func atomsFromJson<K:Atoms>(_ json:String) throws ->K {
        
        let jsonData = json.data(using: .utf8)!
        return try atomsFromData(jsonData)
    }
    
    
    static public func dataFromAtom<K:Atoms>(_ atoms:K) throws ->Data? {
        
        let json = try jsonFromAtoms(atoms)
        return json.data(using: .utf16)
    }
    
    static public func atomsFromData<K:Atoms>(_ jsonData:Data) throws ->K {
        
        let atoms:K = try! JSONDecoder().decode(K.self, from: jsonData)
        return atoms
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
            
            if(MoleculeSerializer.isDictionaryRef(value)){
                //recursion
                result = MoleculeSerializer.nestDictionaries(namespace: childKey,
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
