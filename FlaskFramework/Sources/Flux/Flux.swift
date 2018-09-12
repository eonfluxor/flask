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
public class Flux {
    
    
    /// This is the single bus
    static public let bus = Bus()
    /// Use this to preserve `nil` entries in swift dictionaries
    static public let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in FluxDictRef instances
    static public let Null = NSNull()
    
    
}


public extension Flux {
    
    static public func purgeBusQueue(){
        Flux.bus.busQueue.cancelAllOperations()
    }
    
    static public func purgeFlasks(){
        FluxFlaskManager.purge()
    }
}

public extension Flux {
    
    static public func flask<T:AnyObject>(ownedBy owner:T, binding store:StoreConcrete) -> Flask<T>{
        return Flux.flask(ownedBy:owner,binding:[store])
    }
    
    static public func flask<T:AnyObject>(ownedBy owner:T, binding stores:[StoreConcrete]) -> Flask<T>{
        let flask = Flux.flask(ownedBy:owner)
        flask.defineStores(stores)
        flask.bind()
        return flask
    }
    
    
    static private func flask<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        return FluxFlaskManager.instance(ownedBy:owner)
    }
}


public extension Flux {
    
    static public func lock()->BusLock{
        return BusLock(bus:Flux.bus)
    }
    
    @discardableResult
    static public func lock<T:RawRepresentable>(withEvent enumVal:T)->BusLock{
        return Flux.lock(withEvent:enumVal,payload:nil)
    }
    
    @discardableResult
    static public func lock<T:RawRepresentable>(withEvent enumVal:T, payload:BusPayload?)->BusLock{
        
        let bus = enumVal.rawValue as! String
        let lock = BusLock(bus:Flux.bus)
        
        var info = payload ?? [:]
        info[BUS_LOCKED_BY] = lock
        
        Flux.bus.dispatch(bus,payload:info)
        
        return lock
    }
    
    
    static public func removeLocks(){
        Flux.bus.removeLocks()
    }
}


public extension Flux {
    
    static public func dispatch<T:RawRepresentable>(_ enumVal:T, payload:BusPayload? = nil){
        let bus = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_BUS_NAME] = bus
        
        Flux.bus.dispatch(bus,payload:info)
    }
}




