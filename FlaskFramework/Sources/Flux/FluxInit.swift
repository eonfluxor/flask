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


protocol FlaskReactor{
    
    func flaskReactor( attachedTo:AnyObject, reaction: FlaskReaction)
    
}

func AttachFlask<T:AnyObject & FlaskReactor>( to object:T, mixing stores:[StoreConcrete]){
    Flux.attachFlask(to:object,mixing:stores)
}

func UseFlask<T:AnyObject & FlaskReactor>(_ object:T )->Flask<T>{
    let flasks = FluxFlaskManager.getFlasks(from:object)
    assert(flasks.count > 0, "No Flasks attached. Did you call `AttachFlask(to:mixing:)` ? ")
    assert(flasks.count == 1, "UseFlask required `object` to have only one Flask attached")
    return flasks.first as! Flask<T>
}

extension Flux{
    
    static func attachFlask<T:AnyObject & FlaskReactor>( to object:T, mixing stores:[StoreConcrete]){
       
        let flask = FluxFlaskManager.instance(attachedTo:object)
        flask.defineStores(stores)
        flask.bind()
        flask.reactor = { (owner, reaction) in
            object.flaskReactor(attachedTo: owner, reaction: reaction)
        }
    }
    
    static func detachFlask(in object:AnyObject, mixing:[StoreConcrete]){
        
        assert(FluxFlaskManager.removeFlask(fromOwner: object),"The Flask was not connected, please balance enable/disable calls")
    }
}






