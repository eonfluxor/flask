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
    
    static public func purgeMixersQueue(){
        Lab.mixer.formulationQueue.cancelAllOperations()
    }
    
    static public func purgeFlasks(){
        LabFlaskManager.purge()
    }
}

public extension Lab {
    
    static public func flask<T:AnyObject>(ownedBy owner:T, filling store:StoreConcrete) -> Flask<T>{
        return Lab.flask(ownedBy:owner,filling:[store])
    }
    
    static public func flask<T:AnyObject>(ownedBy owner:T, filling stores:[StoreConcrete]) -> Flask<T>{
        let flask = Lab.flask(ownedBy:owner)
        flask.defineStores(stores)
        flask.fill()
        return flask
    }
    
    
    static private func flask<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        return LabFlaskManager.instance(ownedBy:owner)
    }
}


public extension Lab {
    
    static public func pause()->MixerPause{
        return MixerPause(mixer:Lab.mixer)
    }
    
    @discardableResult
    static public func pause<T:RawRepresentable>(fillingg enumVal:T)->MixerPause{
        return Lab.pause(fillingg:enumVal,payload:nil)
    }
    
    @discardableResult
    static public func pause<T:RawRepresentable>(fillingg enumVal:T, payload:[String:Any]?)->MixerPause{
        
        let mixer = enumVal.rawValue as! String
        let pause = MixerPause(mixer:Lab.mixer)
        
        var info = payload ?? [:]
        info[MIXER_PAUSED_BY] = pause
        
        Lab.mixer.formulate(mixer,payload:info)
        
        return pause
    }
    
    
    static public func removePauses(){
        Lab.mixer.removePauses()
    }
}


public extension Lab {
    
    static public func applyMixer<T:RawRepresentable>(_ enumVal:T){
        Lab.applyMixer(enumVal,payload:nil)
    }
    
    static public func applyMixer<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let mixer = enumVal.rawValue as! String
        var info = payload ?? [:]
        info[FLUX_MIXER_NAME] = mixer
        
        Lab.mixer.formulate(mixer,payload:info)
    }
}




