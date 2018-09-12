//
//  BusLock.swift
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

public class BusLock: FluxEquatable {

    var bus:Bus
    
    required public init(bus:Bus) {

        self.bus = bus
        super.init()
        
        self.bus.addLock(self)
    }
    
    public func release(){
        bus.removeLock(self)
    }
}

public extension Bus{
    
    public func removeLocks(){
        locks=[]
        applyLocks()
    }
    
    func addLock(_ lock:BusLock){
        locks.append(lock)
        applyLocks()
    }
    
    func removeLock(_ lock:BusLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }

    func applyLocks(){
        busQueue.isSuspended = locks.count > 0
    }
    
}
