//
//  FlaskChange.swift
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

public extension FlaskChangeTemplate{
    
    
    public func unwrapValue<A>(_ val:A?) ->A?{
//        if let object = val as? FlaskRef {
//            return object.object as? A
//        }
        return val
    }
    
    public func oldValue<A>()->A?{
        return unwrapValue(oldVal) as? A
    }
    public func newValue<A>()->A?{
        return unwrapValue(newVal) as? A
    }
    
    public func key()->String?{
        return _key
    }
    
    public func molecule()->MoleculeConcrete?{
        return _molecule
    }
}

public struct FlaskChangeTemplate  {
    
    weak var _molecule:MoleculeConcrete?
    var _key:String?
    var oldVal:AnyHashable?
    var newVal:AnyHashable?
    
    func mixd()->Bool{
        
        if isFlaskNil(oldVal) && isFlaskNil(newVal) {
            return false
        }
        
        return !(oldVal == newVal)
    }
    
    mutating func setOldValue<A>(_ val:A?)  {
        oldVal = val as! AnyHashable?
    }
    
    mutating func setNewValue<A>(_ val:A?) {
        newVal = val as! AnyHashable?
    }
    
}

