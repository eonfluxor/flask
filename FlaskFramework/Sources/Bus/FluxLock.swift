//
//  FluxLock.swift
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

public typealias FluxLockReleaseBlock = (_ payload:Any?)->Void
public class FluxLock: FlaskEquatable {

    let bus:Flux
    let _autorelease:Bool
    var onRelease:FluxLockReleaseBlock? = nil
    
    required public init(bus:Flux,autorelease:Bool = false) {
        
        self._autorelease = autorelease
        self.bus = bus
        super.init()
        
        self.bus.addLock(self)
    }
    
    public func release(){
        bus.removeLock(self)
        if let block = onRelease {
            block(nil)
            onRelease = nil
        }
    }
    
    public func autorelease(){
        if !_autorelease { return }
        release()
    }
}

public extension Flux{
    
    public func removeLocks(){
        locks=[]
        applyLocks()
    }
    
    func addLock(_ lock:FluxLock){
        locks.append(lock)
        applyLocks()
    }
    
    func removeLock(_ lock:FluxLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }

    func applyLocks(){
        busQueue.isSuspended = locks.count > 0
    }
    
}
