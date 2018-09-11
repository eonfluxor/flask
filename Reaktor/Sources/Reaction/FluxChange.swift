//
//  FluxChange.swift
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

public extension FluxChangeTemplate{
    
    
    public func unwrapValue<A>(_ val:A?) ->A?{
//        if let object = val as? FluxRef {
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
    
    public func store()->FluxStoreConcrete?{
        return _store
    }
}

public struct FluxChangeTemplate  {
    
    weak var _store:FluxStoreConcrete?
    var _key:String?
    var oldVal:AnyHashable?
    var newVal:AnyHashable?
    
    func mutated()->Bool{
        
        if isFluxNil(oldVal) && isFluxNil(newVal) {
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

