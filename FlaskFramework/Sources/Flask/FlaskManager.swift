//
//  LabFlaskManager.swift
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

class LabFlaskManager{
    
    static var flasks:Array<FlaskConcrete>=[]
    
    static func instance<T:AnyObject>(ownedBy owner:T) -> Flask<T>{
        
        let flask = Flask<T>(owner)
        appendFlask(flask)
        return flask
    }
    
    static func appendFlask(_ flask:FlaskConcrete){
        removeFlask(flask)
        flasks.append(flask)
        LabFlaskManager.purgeOrphans()
    }
    
    static func removeFlask(_ flask:FlaskConcrete){
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
            removeFlask(flask)
        }
    }
}
