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
    
    static var fluxors:Array<FlaskReactorConcrete>=[]
    
    static func instance<T:AnyObject>(ownedBy owner:T) -> FlaskReactor<T>{
        
        let flux = FlaskReactor<T>(owner)
        appendFlaskReactor(flux)
        return flux
    }
    
    static func appendFlaskReactor(_ flux:FlaskReactorConcrete){
        removeFlaskReactor(flux)
        fluxors.append(flux)
        FlaskReactorManager.purgeOrphans()
    }
    
    static func removeFlaskReactor(_ flux:FlaskReactorConcrete){
        if let index = fluxors.index(of: flux) {
            _ = autoreleasepool{
                flux.unbind(false)
                fluxors.remove(at: index)
            }
        }
    }
    
    static func purgeOrphans(){
        let orphans = fluxors.filter {$0.getOwner() == nil}
        
        for flux in orphans {
            removeFlaskReactor(flux)
        }
    }
}
