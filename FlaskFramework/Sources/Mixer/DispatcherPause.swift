//
//  BusPause.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/3/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public class BusPause: FluxEquatable {

    var bus:Bus
    
    required public init(bus:Bus) {

        self.bus = bus
        super.init()
        
        self.bus.addPause(self)
    }
    
    public func release(){
        bus.removePause(self)
    }
}

public extension Bus{
    
    public func removePauses(){
        pauses=[]
        applyPauses()
    }
    
    func addPause(_ pause:BusPause){
        pauses.append(pause)
        applyPauses()
    }
    
    func removePause(_ pause:BusPause){
        pauses=pauses.filter {$0 != pause}
        applyPauses()
    }

    func applyPauses(){
        busQueue.isSuspended = pauses.count > 0
    }
    
}
