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
    func flaskReactions( reaction: FlaskReaction)
}

extension Flask{
    
    static public func substances<T:RawRepresentable>(reactTo enumVal:T, payload:FluxPayloadType? = nil){
        Flask.applyMixer(enumVal, payload: payload)
    }
    
    static public func newSubstance<T:State>(definedBy:T.Type)->Substance<T>{
        return Substance<T>()
    }
    
    static public func newSubstance<T:State>(definedBy:T.Type,named:String,archive:Bool=false)->Substance<T>{
        return Substance<T>(name: named, archive: archive)
    }
    
    static public func getReactor<T:AnyObject & FlaskReactor>(attachedTo object:T )->Reactor<T>{
        let reactors = ReactorManager.getReactors(from:object)
        assert(reactors.count > 0, "No Flasks attached. Did you call `Flask.attachReactor(to:mixing:)` ? ")
        assert(reactors.count == 1, "Flask.getReactor required `object` to have only one Flask attached")
        return reactors.first as! Reactor<T>
    }
    
    static public func attachReactor<T:AnyObject & FlaskReactor>( to object:T, mixing substances:[SubstanceConcrete]){
        
        let reactor = ReactorManager.instance(attachedTo:object)
        reactor.defineSubstances(substances)
        reactor.bind()
        reactor.handler = { (owner, reaction) in
            object.flaskReactions( reaction: reaction)
        }
    }
    
    static public func detachReactor(from object:AnyObject){
        
        assert(ReactorManager.removeReactor(fromOwner: object),"The Flask was not connected, please balance enable/disable calls")
    }
}
