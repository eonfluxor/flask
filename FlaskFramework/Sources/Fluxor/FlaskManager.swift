//
//  FlaskReactorManager.swift
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

class FlaskReactorManager{
    
    static var flasks:Array<FlaskConcrete>=[]
    
    static func instance<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        
        let flask = Flask<T>(owner)
        appendFlaskReactor(flask)
        return flask
    }
    
    static func appendFlaskReactor(_ flask:FlaskConcrete){
        removeFlaskReactor(flask)
        flasks.append(flask)
        FlaskReactorManager.purgeOrphans()
    }
    
    static func removeFlaskReactor(_ flask:FlaskConcrete){
        if let index = flasks.index(of: flask) {
            _ = autoreleasepool{
                flask.unbind(false)
                flasks.remove(at: index)
            }
        }
    }
    
    static func purgeOrphans(){
        let orphans = flasks.filter {$0.getOwner() == nil}
        
        for flask in orphans {
            removeFlaskReactor(flask)
        }
    }
}
