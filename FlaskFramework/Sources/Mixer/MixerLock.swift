//
//  MixerLock.swift
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

public class MixerLock: LabAnyEquatable {

    var mixer:Mixer
    
    required public init(mixer:Mixer) {

        self.mixer = mixer
        super.init()
        
        self.mixer.addLock(self)
    }
    
    public func release(){
        mixer.removeLock(self)
    }
}

public extension Mixer{
    
    public func releaseAllLocks(){
        locks=[]
        applyLocks()
    }
    
    func addLock(_ lock:MixerLock){
        locks.append(lock)
        applyLocks()
    }
    
    func removeLock(_ lock:MixerLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }

    func applyLocks(){
        mixQueue.isSuspended = locks.count > 0
    }
    
}
