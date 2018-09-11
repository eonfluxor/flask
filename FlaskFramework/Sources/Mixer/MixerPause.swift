//
//  MixerPause.swift
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

public class MixerPause: LabAnyEquatable {

    var mixer:Mixer
    
    required public init(mixer:Mixer) {

        self.mixer = mixer
        super.init()
        
        self.mixer.attachPause(self)
    }
    
    public func release(){
        mixer.detachPause(self)
    }
}

public extension Mixer{
    
    public func detachAllPauses(){
        pauses=[]
        applyPauses()
    }
    
    func attachPause(_ pause:MixerPause){
        pauses.append(pause)
        applyPauses()
    }
    
    func detachPause(_ pause:MixerPause){
        pauses=pauses.filter {$0 != pause}
        applyPauses()
    }

    func applyPauses(){
        mixQueue.isSuspended = pauses.count > 0
    }
    
}
