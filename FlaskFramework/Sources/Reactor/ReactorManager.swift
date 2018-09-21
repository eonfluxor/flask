//
//  ReactorManager.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public class ReactorManager{
    
    static public private(set) var reactors:Array<ReactorConcrete>=[]
    
    static func instance<T:AnyObject>(attachedTo owner:T) -> Reactor<T>{
        
        let reactor = Reactor<T>(owner)
        appendReactor(reactor)
        return reactor
    }
    
    static func appendReactor(_ reactor:ReactorConcrete){
        removeReactor(reactor)
        reactors.append(reactor)
        ReactorManager.purge()
    }
    
    static func removeReactor(_ reactor:ReactorConcrete){
        reactor.unbind(explicit:false)
        reactors = reactors.filter{ $0 !== reactor}
    }
    
    @discardableResult
    static func removeReactor(fromOwner owner: AnyObject)->Bool{
        
        let originalCount = reactors.count
        reactors = reactors.filter{ $0.getOwner() !== owner}
        return reactors.count < originalCount
    }
    
    static func getReactors(from owner: AnyObject)->[ReactorConcrete]{
        return reactors.filter{ $0.getOwner() === owner}
    }
    
    static public func purge(){
        let orphans = reactors.filter {$0.getOwner() == nil}
        
        for reactor in orphans {
            removeReactor(reactor)
        }
    }
    
    static public func purgeAll(){
       
        let myReactors = reactors
        for reactor in myReactors {
            removeReactor(reactor)
        }
    }
}
