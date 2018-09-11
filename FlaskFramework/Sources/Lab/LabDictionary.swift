//
//  LabDictRef.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public protocol StateObservable{
    func toLabDictRef()->NSDictionary
}

public class LabDictRef: NSObject, Codable, StateObservable {
   
   
    
    var dictionary = NSDictionary()
    
    override public init(){
        dictionary = NSDictionary()
    }
    
    public init(_ dict:NSDictionary){
        super.init()
        dictionary = normalize( dict )
    }
    
    func normalize(_ dict:NSDictionary)->NSDictionary{
        
        let result = NSMutableDictionary()
        
        for key in dict.allKeys {
            let value = dict[key]
            
             result[key]  = Lab.Nil
            
            if ((value as? NSDictionary) != nil) {
                
                let ref = LabDictRef(normalize( value as! NSDictionary ))
                result[key] = ref
            
            } else {
                result[key] = value as? AnyHashable
            }
            
           
            
        }
        return result
        
    }
    
   
    
    public  func toLabDictRef() -> NSDictionary {
        return dictionary
    }
    
    public  subscript(key: String) -> AnyHashable? {
        get {
            return dictionary[key] as? AnyHashable
        }
        set {
            let mutable = NSMutableDictionary.init(dictionary: dictionary)
            mutable[key]  = newValue
            dictionary = mutable
        }
    }
    
    public  func keys()->Array<String>{
        return  Array(dictionary.allKeys) as! Array<String>
    }
    
    public func count()->Int{
        return dictionary.count
    }
    
    /////
    
    private enum CodingKeys : String, CodingKey {
        case dictionary
    }
    
    static public func == (lhs: LabDictRef, rhs: LabDictRef) -> Bool {
        return lhs == rhs
    }
    
    required public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let jsonString:String = try values.decode(String.self, forKey: .dictionary)
        let data = jsonString.data(using: .utf8)
        let normalDictionary:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
    
        let ref = LabDictRef(normalDictionary)
        dictionary = ref.dictionary
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let normalDict = SubstanceSerializer.flattenDictionary(self)
        
        let jsonData:Data = try JSONSerialization.data(withJSONObject: normalDict, options: [])
        let string:String = String(data: jsonData, encoding: .utf8)!
        try container.encode(string, forKey: .dictionary)
    
    }

}

