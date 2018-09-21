
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
    
    lazy var reactorRefs: Dictionary<String, Array<FlaskWeakRef<ReactorConcrete>>> = {
        return Dictionary<String, Array<FlaskWeakRef<ReactorConcrete>>>()
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
        
        
        let operation = FlaskOperation{ [weak self] (operation) in

            assert( self?.currentMixer == .none, "The single flow is broken!")
            self?.currentMixer = mixer
            
            FluxNotifier.postNotification(forMixer: mixer,
                                          payload: payload,
                                          operation: operation)
            
            
            self?.currentMixer = .none
            
        }
        
        busQueue.addOperation(operation)
        
    }
    
    
    
    func performInFluxQueue(_ action:@escaping ()->Void){
        
        busQueue.addOperation {
            action()
        }

    }
    
    func applyMixerInLockQueue(_ mixer:String, payload:FluxPayloadType?){
   
         let operation = FlaskOperation{  (operation) in
            FluxNotifier.postNotification(forMixer: mixer,
                                         payload: payload,
                                         operation: operation)
            
        }
        
        busOnLockQueue.addOperation(operation)
    }
 
}



//////////////////
// MARK: - BINDINGS

extension Flux {
   
    func bindFlask(_ substance:SubstanceConcrete, reactor:ReactorConcrete) {
        
        let substanceName = substance.name()
        var substanceFlaskNSRefs = getSubstanceFlaskNSRefs(substanceName)
        
        let ref = FlaskWeakRef(value:reactor)
        substanceFlaskNSRefs.append(ref)
        setSubstanceFlaskNSRefs(substanceName,substanceFlaskNSRefs)
        
    }
    
    func unbindFlask(_ substance:SubstanceConcrete, reactor:ReactorConcrete) {
        
        let substanceName = substance.name()
        let substanceFlaskNSRefs = getSubstanceFlaskNSRefs(substanceName)
        
        let substanceFlaskNSRefsFiltered = substanceFlaskNSRefs.filter { $0.value != reactor }
        
        setSubstanceFlaskNSRefs(substanceName,substanceFlaskNSRefsFiltered)
       
    }
    
    func getSubstanceFlaskNSRefs(_ substanceName:String) -> Array<FlaskWeakRef<ReactorConcrete>>{
        
        if let reactors = self.reactorRefs[substanceName] {
            return reactors
        }
        
        return Array<FlaskWeakRef<ReactorConcrete>>()
        
    }
    
    func setSubstanceFlaskNSRefs(_ substanceName:String,_ refs:Array<FlaskWeakRef<ReactorConcrete>>){
        
        self.reactorRefs[substanceName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension Flux {
   
    func reactChange(_ reaction:FlaskReaction){
        
        let substanceName = reaction.substance.name()
        let substanceFlaskNSRefs = getSubstanceFlaskNSRefs(substanceName)
        
        for substanceFlaskNSRef in substanceFlaskNSRefs {
            if let reactor = substanceFlaskNSRef.value{
                reactor.handleReaction( reaction)
            }
        }
        
    }

}
