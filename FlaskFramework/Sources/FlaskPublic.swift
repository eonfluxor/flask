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
    
    
    /// This is the single dispatcher
    static public let Dispatcher = FlaskDispatcher()
    /// Use this to preserve `nil` entries in swift dictionaries
    static public let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in FlaskDictionaryRef instances
    static public let Null = NSNull()
    
    
}


public extension Flask {
    
    static public func disposeDispatchQueue(){
        Flask.Dispatcher.dispatchQueue.cancelAllOperations()
    }
    
    static public func purgeOrphans(){
        FlaskReactorManager.purgeOrphans()
    }
}

public extension Flask {
    
    static public func instance<T:AnyObject>(ownedBy owner:T, binding store:FlaskStoreConcrete) -> FlaskReactor<T>{
        return Flask.instance(ownedBy:owner,binding:[store])
    }
    
    static public func instance<T:AnyObject>(ownedBy owner:T, binding stores:[FlaskStoreConcrete]) -> FlaskReactor<T>{
        let flux = Flask.instance(ownedBy:owner)
        flux.bindStores(stores)
        return flux
    }
    
    
    static public func instance<T:AnyObject>(ownedBy owner:T) -> FlaskReactor<T>{
        return FlaskReactorManager.instance(ownedBy:owner)
    }
}


public extension Flask {
    
    static public func lock()->FlaskLock{
        return FlaskLock(dispatcher:Flask.Dispatcher)
    }
    
    
    static public func lock<T:RawRepresentable>(action enumVal:T)->FlaskLock{
        return Flask.lock(action:enumVal,payload:nil)
    }
    
    static public func lock<T:RawRepresentable>(action enumVal:T, payload:[String:Any]?)->FlaskLock{
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_SKIP_LOCKS] = true
        
        let lock = FlaskLock(dispatcher:Flask.Dispatcher)
        Flask.Dispatcher.dispatch(action,payload:info)
        
        return lock
    }
    
    
    static public func releaseAllLocks(){
        Flask.Dispatcher.releaseAllLocks()
    }
}


public extension Flask {
    
    static public func action<T:RawRepresentable>(_ enumVal:T){
        Flask.action(enumVal,payload:nil)
    }
    
    static public func action<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_NAME] = action
        
        Flask.Dispatcher.dispatch(action,payload:info)
    }
}




