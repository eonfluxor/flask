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
    func flaskReactor( attachedTo:AnyObject, reaction: FlaskReaction)
}

public func FlaskAttach<T:AnyObject & FlaskReactor>( to object:T, mixing substances:[SubstanceConcrete]){
    Flux.attachFlask(to:object,mixing:substances)
}

public func FlaskDetach<T:AnyObject & FlaskReactor>( from object:T){
    Flux.detachFlask(from:object)
}


public func FlaskUse<T:AnyObject & FlaskReactor>(_ object:T )->Flask<T>{
    let flasks = FluxFlaskManager.getFlasks(from:object)
    assert(flasks.count > 0, "No Flasks attached. Did you call `AttachFlask(to:mixing:)` ? ")
    assert(flasks.count == 1, "UseFlask required `object` to have only one Flask attached")
    return flasks.first as! Flask<T>
}


extension Flux{
    
    static public func attachFlask<T:AnyObject & FlaskReactor>( to object:T, mixing substances:[SubstanceConcrete]){
        
        let flask = FluxFlaskManager.instance(attachedTo:object)
        flask.defineSubstances(substances)
        flask.bind()
        flask.reactor = { (owner, reaction) in
            object.flaskReactor(attachedTo: owner, reaction: reaction)
        }
    }
    
    static public func detachFlask(from object:AnyObject){
        
        assert(FluxFlaskManager.removeFlask(fromOwner: object),"The Flask was not connected, please balance enable/disable calls")
    }
}
