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

class FluxLock: FluxAnyEquatable {

    var dispatcher:FluxDispatcher
    
    required init(dispatcher:FluxDispatcher) {

        self.dispatcher = dispatcher
        super.init()
        
        self.dispatcher.addLock(self)
    }
    
    func release(){
        dispatcher.removeLock(self)
    }
}

extension FluxDispatcher{
    
    func addLock(_ lock:FluxLock){
        locks.append(lock)
        applyLocks()
    }
    
    func removeLock(_ lock:FluxLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }
    
    func releaseAllLocks(){
        locks=[]
        applyLocks()
    }
    
    func applyLocks(){
        dispatchQueue.isSuspended = locks.count > 0
    }
    
}
