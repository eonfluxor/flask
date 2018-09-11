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
public class Lab {
    
    
    /// This is the single dispatcher
    static public let Dispatcher = FlaskDispatcher()
    /// Use this to preserve `nil` entries in swift dictionaries
    static public let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in FlaskDictionaryRef instances
    static public let Null = NSNull()
    
    
}


public extension Lab {
    
    static public func disposeDispatchQueue(){
        Lab.Dispatcher.dispatchQueue.cancelAllOperations()
    }
    
    static public func purgeOrphans(){
        FlaskReactorManager.purgeOrphans()
    }
}

public extension Lab {
    
    static public func flask<T:AnyObject>(ownedBy owner:T, binding store:MoleculeConcrete) -> Flask<T>{
        return Lab.flask(ownedBy:owner,binding:[store])
    }
    
    static public func flask<T:AnyObject>(ownedBy owner:T, binding stores:[MoleculeConcrete]) -> Flask<T>{
        let flask = Lab.flask(ownedBy:owner)
        flask.bindMolecules(stores)
        return flask
    }
    
    
    static public func flask<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        return FlaskReactorManager.instance(ownedBy:owner)
    }
}


public extension Lab {
    
    static public func lock()->FlaskLock{
        return FlaskLock(dispatcher:Lab.Dispatcher)
    }
    
    
    static public func lock<T:RawRepresentable>(action enumVal:T)->FlaskLock{
        return Lab.lock(action:enumVal,payload:nil)
    }
    
    static public func lock<T:RawRepresentable>(action enumVal:T, payload:[String:Any]?)->FlaskLock{
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_SKIP_LOCKS] = true
        
        let lock = FlaskLock(dispatcher:Lab.Dispatcher)
        Lab.Dispatcher.dispatch(action,payload:info)
        
        return lock
    }
    
    
    static public func releaseAllLocks(){
        Lab.Dispatcher.releaseAllLocks()
    }
}


public extension Lab {
    
    static public func action<T:RawRepresentable>(_ enumVal:T){
        Lab.action(enumVal,payload:nil)
    }
    
    static public func action<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let action = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_NAME] = action
        
        Lab.Dispatcher.dispatch(action,payload:info)
    }
}




