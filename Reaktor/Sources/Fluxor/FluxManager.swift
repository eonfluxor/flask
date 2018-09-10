//
//  FluxorManager.swift
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

class FluxorManager{
    
    static var fluxors:Array<FluxorConcrete>=[]
    
    static func instance<T:AnyObject>(ownedBy owner:T) -> Fluxor<T>{
        
        let flux = Fluxor<T>(owner)
        appendFluxor(flux)
        return flux
    }
    
    static func appendFluxor(_ flux:FluxorConcrete){
        removeFluxor(flux)
        fluxors.append(flux)
        FluxorManager.purgeOrphans()
    }
    
    static func removeFluxor(_ flux:FluxorConcrete){
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
            removeFluxor(flux)
        }
    }
}
