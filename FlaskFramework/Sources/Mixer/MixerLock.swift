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
        
        self.mixer.attachLock(self)
    }
    
    public func release(){
        mixer.detachLock(self)
    }
}

public extension Mixer{
    
    public func detachAllLocks(){
        locks=[]
        applyLocks()
    }
    
    func attachLock(_ lock:MixerLock){
        locks.append(lock)
        applyLocks()
    }
    
    func detachLock(_ lock:MixerLock){
        locks=locks.filter {$0 != lock}
        applyLocks()
    }

    func applyLocks(){
        mixQueue.isSuspended = locks.count > 0
    }
    
}
