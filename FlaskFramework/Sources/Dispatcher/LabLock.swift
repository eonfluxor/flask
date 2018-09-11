//
//  LabLock.swift
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

public class LabLock: LabAnyEquatable {

    var dispatcher:LabDispatcher
    
    required public init(dispatcher:LabDispatcher) {

        self.dispatcher = dispatcher
        super.init()
        
        self.dispatcher.addLock(self)
    }
    
    public func release(){
        dispatcher.removeLock(self)
    }
}

public extension LabDispatcher{
    
    public func releaseAllLocks(){
        locks=[]
        applyLocks()
    }
    
    func addLock(_ lock:LabLock){
        locks.append(lock)
        applyLocks()
    }
    
    func removeLock(_ lock:LabLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }

    func applyLocks(){
        dispatchQueue.isSuspended = locks.count > 0
    }
    
}
