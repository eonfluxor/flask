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
        FlaskFlaskManager.purge()
    }
}

public extension Flask {
    
    static public func instance<T:AnyObject>(attachedTo owner:T, mixing substance:SubstanceConcrete) -> FlaskClass<T>{
        return Flask.instance(attachedTo:owner,mixing:[substance])
    }
    
    static public func instance<T:AnyObject>(attachedTo owner:T, mixing substances:[SubstanceConcrete]) -> FlaskClass<T>{
        let flask = Flask.instance(attachedTo:owner)
        flask.defineSubstances(substances)
        flask.bind()
        return flask
    }
    
    
    static private func instance<T:AnyObject>(attachedTo owner:T) -> FlaskClass<T>{
        return FlaskFlaskManager.instance(attachedTo:owner)
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
    static public func lock<T:RawRepresentable>(withMixer enumVal:T, payload:FluxPayload?)->FluxLock{
        
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
    
    static public func applyMixer<T:RawRepresentable>(_ enumVal:T, payload:FluxPayload? = nil){
        let bus = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_BUS_NAME] = bus
        
        Flask.bus.applyMixer(bus,payload:info)
    }
}




