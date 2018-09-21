//
//  FlaskPublic.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/3/18.
//  Copy pod 'Delayed', '~> 2.2.2'right © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif


/// Main entry point
public class Flask {
    
    
    /// This is the single bus
    static public let bus = Flux()
    /// Use this to preserve `nil` entries in swift dictionaries
    static public let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in FlaskDictRef instances
    static public let Null = NSNull()
    
    
}


public extension Flask {
    
    static public func purgeFluxQueue(){
        Flask.bus.busQueue.cancelAllOperations()
    }
    
    static public func purgeFlasks(){
        ReactorManager.purge()
    }
}

public extension Flask {
    
    static public func reactor<T:AnyObject>(attachedTo owner:T, mixing substance:SubstanceConcrete) -> Reactor<T>{
        return Flask.reactor(attachedTo:owner,mixing:[substance])
    }
    
    static public func reactor<T:AnyObject>(attachedTo owner:T, mixing substances:[SubstanceConcrete]) -> Reactor<T>{
        let reactor = Flask.reactor(attachedTo:owner)
        reactor.defineSubstances(substances)
        reactor.bind()
        return reactor
    }
    
    
    static private func reactor<T:AnyObject>(attachedTo owner:T) -> Reactor<T>{
        return ReactorManager.instance(attachedTo:owner)
    }
}


public extension Flask {
    
    static public func lock()->FluxLock{
        return FluxLock(bus:Flask.bus)
    }
    
    @discardableResult
    static public func lock<T:RawRepresentable>(withMixer enumVal:T)->FluxLock{
        return Flask.lock(withMixer:enumVal,payload:nil)
    }
    
    @discardableResult
    static public func lock<T:RawRepresentable>(withMixer enumVal:T, payload:FluxPayloadType?)->FluxLock{
        
        let bus = enumVal.rawValue as! String
        let lock = FluxLock(bus:Flask.bus)
        
        var info = payload ?? [:]
        info[BUS_LOCKED_BY] = lock
        
        Flask.bus.applyMixer(bus,payload:info)
        
        return lock
    }
    
    
    static public func removeLocks(){
        Flask.bus.removeLocks()
    }
}


public extension Flask {
    
    static public func applyMixer<T:RawRepresentable>(_ enumVal:T, payload:FluxPayloadType? = nil){
        let bus = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_BUS_NAME] = bus
        
        Flask.bus.applyMixer(bus,payload:info)
    }
}




