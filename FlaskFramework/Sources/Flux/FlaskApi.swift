//
//  FlaskOwner.swift
//  Flask-iOS
//
//  Created by hassan uriostegui on 9/11/18.
//  Copyright © 2018 eonflux. All rights reserved.
//
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif


public protocol FlaskReactor{
    func flaskReactor( reaction: FlaskReaction)
}

public func AttachFlaskReactor<T:AnyObject & FlaskReactor>( to object:T, mixing substances:[SubstanceConcrete]){
    Flask.attachFlask(to:object,mixing:substances)
}


public func DetachFlaskReactor<T:AnyObject & FlaskReactor>( from object:T){
    Flask.detachFlask(from:object)
}


public func UseFlaskReactor<T:AnyObject & FlaskReactor>(at object:T )->FlaskClass<T>{
    let flasks = FlaskFlaskManager.getFlasks(from:object)
    assert(flasks.count > 0, "No Flasks attached. Did you call `AttachFlaskReactor(to:mixing:)` ? ")
    assert(flasks.count == 1, "UseFlaskReactor required `object` to have only one Flask attached")
    return flasks.first as! FlaskClass<T>
}

public func MixSubstances<T:RawRepresentable>(with enumVal:T, payload:FluxPayloadType? = nil){
    Flask.applyMixer(enumVal, payload: payload)
}


extension Flask{
    
    static public func attachFlask<T:AnyObject & FlaskReactor>( to object:T, mixing substances:[SubstanceConcrete]){
        
        let flask = FlaskFlaskManager.instance(attachedTo:object)
        flask.defineSubstances(substances)
        flask.bind()
        flask.reactor = { (owner, reaction) in
            object.flaskReactor( reaction: reaction)
        }
    }
    
    static public func detachFlask(from object:AnyObject){
        
        assert(FlaskFlaskManager.removeFlask(fromOwner: object),"The Flask was not connected, please balance enable/disable calls")
    }
}
