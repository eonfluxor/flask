//
//  FlaskManager.swift
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

class FlaskManager{
    
    static var flasks:Array<FlaskConcrete>=[]
    
    static func instance<T:AnyObject>(attachedTo owner:T) -> FlaskClass<T>{
        
        let flask = FlaskClass<T>(owner)
        appendFlask(flask)
        return flask
    }
    
    static func appendFlask(_ flask:FlaskConcrete){
        removeFlask(flask)
        flasks.append(flask)
        FlaskManager.purge()
    }
    
    static func removeFlask(_ flask:FlaskConcrete){
        flask.unbind(explicit:false)
        flasks = flasks.filter{ $0 !== flask}
    }
    
    @discardableResult
    static func removeFlask(fromOwner owner: AnyObject)->Bool{
        
        let originalCount = flasks.count
        flasks = flasks.filter{ $0.getOwner() !== owner}
        return flasks.count < originalCount
    }
    
    static func getFlasks(from owner: AnyObject)->[FlaskConcrete]{
        return flasks.filter{ $0.getOwner() === owner}
    }
    
    static func purge(){
        let orphans = flasks.filter {$0.getOwner() == nil}
        
        for flask in orphans {
            removeFlask(flask)
        }
    }
}
