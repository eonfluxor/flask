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
    static let Dispatcher = FluxDispatcher()
    /// Use this to preserve `nil` entries in swift dictionaries
    static let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in FluxDictionaryRef instances
    static let Null = NSNull()
    
    
}


extension Flux {
    
    static func disposeDispatchQueue(){
        Flux.Dispatcher.dispatchQueue.cancelAllOperations()
    }
    
    static func purgeOrphans(){
        FluxorManager.purgeOrphans()
    }
}

extension Flux {
    
    static func instance<T:AnyObject>(ownedBy owner:T, binding store:FluxStoreConcrete) -> Fluxor<T>{
        return Flux.instance(ownedBy:owner,binding:[store])
    }
    
    static func instance<T:AnyObject>(ownedBy owner:T, binding stores:[FluxStoreConcrete]) -> Fluxor<T>{
        let flux = Flux.instance(ownedBy:owner)
        flux.bindStores(stores)
        return flux
    }
    
    
    static func instance<T:AnyObject>(ownedBy owner:T) -> Fluxor<T>{
        return FluxorManager.instance(ownedBy:owner)
    }
}


extension Flux {
    
    static func lock()->FluxLock{
        return FluxLock(dispatcher:Flux.Dispatcher)
    }
    
    
    static func lock<T:RawRepresentable>(action enumVal:T)->FluxLock{
        return Flux.lock(action:enumVal,payload:nil)
    }
    
    static func lock<T:RawRepresentable>(action enumVal:T, payload:[String:Any]?)->FluxLock{
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_SKIP_LOCKS] = true
        
        let lock = FluxLock(dispatcher:Flux.Dispatcher)
        Flux.Dispatcher.dispatch(action,payload:info)
        
        return lock
    }
    
    
    static func releaseAllLocks(){
        Flux.Dispatcher.releaseAllLocks()
    }
}


extension Flux {
    
    static func action<T:RawRepresentable>(_ enumVal:T){
        Flux.action(enumVal,payload:nil)
    }
    
    static func action<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_NAME] = action
        
        Flux.Dispatcher.dispatch(action,payload:info)
    }
}




