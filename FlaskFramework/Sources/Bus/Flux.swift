
//
//  bus.swift
//  SwiftyFlask
//
//  Created by hassan uriostegui on 8/28/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public class Flux {
    
    //////////////////
    // MARK: - LOCKS
    
    var locks:[FluxLock]=[]
    
    //////////////////
    // MARK: - OPERATION QUEUE
    
    let busQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    let busOnLockQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    

    //////////////////
    // MARK: - OPTIONALS
    
    var currentMixer: String?
    
    //////////////////
    // MARK: - LAZY
    
    lazy var flaskRefs: Dictionary<String, Array<FlaskWeakRef<FlaskConcrete>>> = {
        return Dictionary<String, Array<FlaskWeakRef<FlaskConcrete>>>()
    }();
    
    func lock()->FluxLock{
        return FluxLock(bus:self)
    }
    
}
    
//////////////////
// MARK: - PUBLIC METHODS

extension Flux {
    
    func applyMixer<T:RawRepresentable>(_ enumVal:T, payload:FluxPayloadType? = nil){
        let bus = enumVal.rawValue as! String
        applyMixer(bus,payload:payload)
    }
    
    func applyMixer(_ bus:String, payload:FluxPayloadType? = nil ){
        enqueue(bus,payload: payload)
    }
    
}

//////////////////
// MARK: - QUEUE

extension Flux {
 
    func enqueue(_ mixer:String, payload:FluxPayloadType?){
        
        if (payload?[BUS_LOCKED_BY]) == nil {
            applyMixerInFluxQueue(mixer,payload:payload)
        }else{
            applyMixerInLockQueue(mixer,payload:payload)
        }
        
    }
    
    func applyMixerInFluxQueue(_ mixer:String, payload:FluxPayloadType?){
        
        let completed = { [weak self] in
            if let me = self{
                me.applyLocks()
            }
        }
        
        busQueue.addOperation { [weak self] in
            
  
            assert( self?.currentMixer == .none, "The sngle flow is broken!")
            self?.currentMixer = mixer
            
            FluxNotifier.postNotification(forMixer: mixer,
                                         payload: payload,
                                         completion: completed)
            
            
            self?.currentMixer = .none
            
        }
        
        busQueue.isSuspended = true
    }
    
    func performInFluxQueue(_ action:@escaping ()->Void){
        
        busQueue.addOperation {
            action()
        }

    }
    
    func applyMixerInLockQueue(_ mixer:String, payload:FluxPayloadType?){
        
        let completed = { [weak self] in
            if let me = self{
                me.busOnLockQueue.isSuspended = false
            }
        }
        
        busOnLockQueue.addOperation {
            FluxNotifier.postNotification(forMixer: mixer,
                                         payload: payload,
                                         completion: completed)
            
        }
        
        busOnLockQueue.isSuspended = true
    }
 
}



//////////////////
// MARK: - BINDINGS

extension Flux {
   
    func bindFlask(_ substance:SubstanceConcrete, flask:FlaskConcrete) {
        
        let substanceName = substance.name()
        var substanceFlaskNSRefs = getSubstanceFlaskNSRefs(substanceName)
        
        let ref = FlaskWeakRef(value:flask)
        substanceFlaskNSRefs.append(ref)
        setSubstanceFlaskNSRefs(substanceName,substanceFlaskNSRefs)
        
    }
    
    func unbindFlask(_ substance:SubstanceConcrete, flask:FlaskConcrete) {
        
        let substanceName = substance.name()
        let substanceFlaskNSRefs = getSubstanceFlaskNSRefs(substanceName)
        
        let substanceFlaskNSRefsFiltered = substanceFlaskNSRefs.filter { $0.value != flask }
        
        setSubstanceFlaskNSRefs(substanceName,substanceFlaskNSRefsFiltered)
       
    }
    
    func getSubstanceFlaskNSRefs(_ substanceName:String) -> Array<FlaskWeakRef<FlaskConcrete>>{
        
        if let flasks = self.flaskRefs[substanceName] {
            return flasks
        }
        
        return Array<FlaskWeakRef<FlaskConcrete>>()
        
    }
    
    func setSubstanceFlaskNSRefs(_ substanceName:String,_ refs:Array<FlaskWeakRef<FlaskConcrete>>){
        
        self.flaskRefs[substanceName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension Flux {
   
    func reactChange(_ reaction:FlaskReaction){
        
        let substanceName = reaction.substance.name()
        let substanceFlaskNSRefs = getSubstanceFlaskNSRefs(substanceName)
        
        for substanceFlaskNSRef in substanceFlaskNSRefs {
            if let flask = substanceFlaskNSRef.value{
                flask.handleReaction( reaction)
            }
        }
        
    }

}
