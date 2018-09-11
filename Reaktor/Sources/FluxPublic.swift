//
//  FluxPublic.swift
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
    
    
    /// This is the single dispatcher
    static public let Dispatcher = FluxDispatcher()
    /// Use this to preserve `nil` entries in swift dictionaries
    static public let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in FluxDictionaryRef instances
    static public let Null = NSNull()
    
    
}


public extension Flux {
    
    static public func disposeDispatchQueue(){
        Flux.Dispatcher.dispatchQueue.cancelAllOperations()
    }
    
    static public func purgeOrphans(){
        FluxorManager.purgeOrphans()
    }
}

public extension Flux {
    
    static public func instance<T:AnyObject>(ownedBy owner:T, binding store:FluxStoreConcrete) -> Fluxor<T>{
        return Flux.instance(ownedBy:owner,binding:[store])
    }
    
    static public func instance<T:AnyObject>(ownedBy owner:T, binding stores:[FluxStoreConcrete]) -> Fluxor<T>{
        let flux = Flux.instance(ownedBy:owner)
        flux.bindStores(stores)
        return flux
    }
    
    
    static public func instance<T:AnyObject>(ownedBy owner:T) -> Fluxor<T>{
        return FluxorManager.instance(ownedBy:owner)
    }
}


public extension Flux {
    
    static public func lock()->FluxLock{
        return FluxLock(dispatcher:Flux.Dispatcher)
    }
    
    
    static public func lock<T:RawRepresentable>(action enumVal:T)->FluxLock{
        return Flux.lock(action:enumVal,payload:nil)
    }
    
    static public func lock<T:RawRepresentable>(action enumVal:T, payload:[String:Any]?)->FluxLock{
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_SKIP_LOCKS] = true
        
        let lock = FluxLock(dispatcher:Flux.Dispatcher)
        Flux.Dispatcher.dispatch(action,payload:info)
        
        return lock
    }
    
    
    static public func releaseAllLocks(){
        Flux.Dispatcher.releaseAllLocks()
    }
}


public extension Flux {
    
    static public func action<T:RawRepresentable>(_ enumVal:T){
        Flux.action(enumVal,payload:nil)
    }
    
    static public func action<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_NAME] = action
        
        Flux.Dispatcher.dispatch(action,payload:info)
    }
}




