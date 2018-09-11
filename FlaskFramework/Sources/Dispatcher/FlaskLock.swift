//
//  FlaskLock.swift
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

public class FlaskLock: FlaskAnyEquatable {

    var dispatcher:FlaskDispatcher
    
    required public init(dispatcher:FlaskDispatcher) {

        self.dispatcher = dispatcher
        super.init()
        
        self.dispatcher.addLock(self)
    }
    
    public func release(){
        dispatcher.removeLock(self)
    }
}

public extension FlaskDispatcher{
    
    public func releaseAllLocks(){
        locks=[]
        applyLocks()
    }
    
    func addLock(_ lock:FlaskLock){
        locks.append(lock)
        applyLocks()
    }
    
    func removeLock(_ lock:FlaskLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }

    func applyLocks(){
        dispatchQueue.isSuspended = locks.count > 0
    }
    
}
