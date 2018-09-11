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
    
    static public func flask<T:AnyObject>(ownedBy owner:T, filling store:StoreConcrete) -> Flask<T>{
        return Flux.flask(ownedBy:owner,filling:[store])
    }
    
    static public func flask<T:AnyObject>(ownedBy owner:T, filling stores:[StoreConcrete]) -> Flask<T>{
        let flask = Flux.flask(ownedBy:owner)
        flask.defineStores(stores)
        flask.fill()
        return flask
    }
    
    
    static private func flask<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        return FluxFlaskManager.instance(ownedBy:owner)
    }
}


public extension Flux {
    
    static public func pause()->BusPause{
        return BusPause(bus:Flux.bus)
    }
    
    @discardableResult
    static public func pause<T:RawRepresentable>(fillingg enumVal:T)->BusPause{
        return Flux.pause(fillingg:enumVal,payload:nil)
    }
    
    @discardableResult
    static public func pause<T:RawRepresentable>(fillingg enumVal:T, payload:[String:Any]?)->BusPause{
        
        let bus = enumVal.rawValue as! String
        let pause = BusPause(bus:Flux.bus)
        
        var info = payload ?? [:]
        info[BUS_PAUSED_BY] = pause
        
        Flux.bus.transmute(bus,payload:info)
        
        return pause
    }
    
    
    static public func removePauses(){
        Flux.bus.removePauses()
    }
}


public extension Flux {
    
    static public func transmute<T:RawRepresentable>(_ enumVal:T){
        Flux.transmute(enumVal,payload:nil)
    }
    
    static public func transmute<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let bus = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_BUS_NAME] = bus
        
        Flux.bus.transmute(bus,payload:info)
    }
}




