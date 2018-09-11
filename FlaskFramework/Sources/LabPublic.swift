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
    
    
    /// This is the single mixer
    static public let mixer = Mixer()
    /// Use this to preserve `nil` entries in swift dictionaries
    static public let Nil = nil as AnyHashable?
    /// Use this to preseve `nul` in LabDictRef instances
    static public let Null = NSNull()
    
    
}


public extension Lab {
    
    static public func disposeDispatchQueue(){
        Lab.mixer.mixQueue.cancelAllOperations()
    }
    
    static public func purge(){
        LabFlaskManager.purge()
    }
}

public extension Lab {
    
    static public func flask<T:AnyObject>(ownedBy owner:T, mixin molecule:MoleculeConcrete) -> Flask<T>{
        return Lab.flask(ownedBy:owner,mixin:[molecule])
    }
    
    static public func flask<T:AnyObject>(ownedBy owner:T, mixin molecules:[MoleculeConcrete]) -> Flask<T>{
        let flask = Lab.flask(ownedBy:owner)
        flask.bindMolecules(molecules)
        return flask
    }
    
    
    static private func flask<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        return LabFlaskManager.instance(ownedBy:owner)
    }
}


public extension Lab {
    
    static public func lock()->MixerLock{
        return MixerLock(mixer:Lab.mixer)
    }
    
    
    static public func lock<T:RawRepresentable>(mixer enumVal:T)->MixerLock{
        return Lab.lock(mixer:enumVal,payload:nil)
    }
    
    static public func lock<T:RawRepresentable>(mixer enumVal:T, payload:[String:Any]?)->MixerLock{
        let mixer = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_SKIP_LOCKS] = true
        
        let lock = MixerLock(mixer:Lab.mixer)
        Lab.mixer.formulate(mixer,payload:info)
        
        return lock
    }
    
    
    static public func detachAllLocks(){
        Lab.mixer.detachAllLocks()
    }
}


public extension Lab {
    
    static public func mix<T:RawRepresentable>(_ enumVal:T){
        Lab.mix(enumVal,payload:nil)
    }
    
    static public func mix<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let mixer = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_ACTION_NAME] = mixer
        
        Lab.mixer.formulate(mixer,payload:info)
    }
}




