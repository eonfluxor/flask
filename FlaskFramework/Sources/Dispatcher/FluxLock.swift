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

public class FluxLock: FluxAnyEquatable {

    var dispatcher:FluxDispatcher
    
    required public init(dispatcher:FluxDispatcher) {

        self.dispatcher = dispatcher
        super.init()
        
        self.dispatcher.addLock(self)
    }
    
    public func release(){
        dispatcher.removeLock(self)
    }
}

public extension FluxDispatcher{
    
    public func releaseAllLocks(){
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
        dispatchQueue.isSuspended = locks.count > 0
    }
    
}
