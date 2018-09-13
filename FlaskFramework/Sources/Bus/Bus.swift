
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

public class Bus {
    
    //////////////////
    // MARK: - LOCKS
    
    var locks:[BusLock]=[]
    
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
    
    var currentEvent: String?
    
    //////////////////
    // MARK: - LAZY
    
    lazy var flaskRefs: Dictionary<String, Array<FluxWeakRef<FlaskConcrete>>> = {
        return Dictionary<String, Array<FluxWeakRef<FlaskConcrete>>>()
    }();
    
    func lock()->BusLock{
        return BusLock(bus:self)
    }
    
}
    
//////////////////
// MARK: - PUBLIC METHODS

extension Bus {
    
    func applyMixer<T:RawRepresentable>(_ enumVal:T, payload:BusPayload? = nil){
        let bus = enumVal.rawValue as! String
        applyMixer(bus,payload:payload)
    }
    
    func applyMixer(_ bus:String, payload:BusPayload? = nil ){
        enqueue(bus,payload: payload)
    }
    
}

//////////////////
// MARK: - QUEUE

extension Bus {
 
    func enqueue(_ event:String, payload:BusPayload?){
        
        if (payload?[BUS_LOCKED_BY]) == nil {
            applyMixerInBusQueue(event,payload:payload)
        }else{
            applyMixerInLockQueue(event,payload:payload)
        }
        
    }
    
    func applyMixerInBusQueue(_ event:String, payload:BusPayload?){
        
        let completed = { [weak self] in
            if let me = self{
                me.applyLocks()
            }
        }
        
        busQueue.addOperation { [weak self] in
            
  
            assert( self?.currentEvent == .none, "The sngle flow is broken!")
            self?.currentEvent = event
            
            BusNotifier.postNotification(forEvent: event,
                                         payload: payload,
                                         completion: completed)
            
            
            self?.currentEvent = .none
            
        }
        
        busQueue.isSuspended = true
    }
    
    func performInBusQueue(_ action:@escaping ()->Void){
        
        busQueue.addOperation {
            action()
        }

    }
    
    func applyMixerInLockQueue(_ event:String, payload:BusPayload?){
        
        let completed = { [weak self] in
            if let me = self{
                me.busOnLockQueue.isSuspended = false
            }
        }
        
        busOnLockQueue.addOperation {
            BusNotifier.postNotification(forEvent: event,
                                         payload: payload,
                                         completion: completed)
            
        }
        
        busOnLockQueue.isSuspended = true
    }
 
}



//////////////////
// MARK: - BINDINGS

extension Bus {
   
    func bindFlask(_ substance:SubstanceConcrete, flask:FlaskConcrete) {
        
        let substanceName = substance.name()
        var substanceFlaskRefs = getSubstanceFlaskRefs(substanceName)
        
        let ref = FluxWeakRef(value:flask)
        substanceFlaskRefs.append(ref)
        setSubstanceFlaskRefs(substanceName,substanceFlaskRefs)
        
    }
    
    func unbindFlask(_ substance:SubstanceConcrete, flask:FlaskConcrete) {
        
        let substanceName = substance.name()
        let substanceFlaskRefs = getSubstanceFlaskRefs(substanceName)
        
        let substanceFlaskRefsFiltered = substanceFlaskRefs.filter { $0.value != flask }
        
        setSubstanceFlaskRefs(substanceName,substanceFlaskRefsFiltered)
       
    }
    
    func getSubstanceFlaskRefs(_ substanceName:String) -> Array<FluxWeakRef<FlaskConcrete>>{
        
        if let flasks = self.flaskRefs[substanceName] {
            return flasks
        }
        
        return Array<FluxWeakRef<FlaskConcrete>>()
        
    }
    
    func setSubstanceFlaskRefs(_ substanceName:String,_ refs:Array<FluxWeakRef<FlaskConcrete>>){
        
        self.flaskRefs[substanceName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension Bus {
   
    func reactChange(_ reaction:FlaskReaction){
        
        let substanceName = reaction.substance.name()
        let substanceFlaskRefs = getSubstanceFlaskRefs(substanceName)
        
        for substanceFlaskRef in substanceFlaskRefs {
            if let flask = substanceFlaskRef.value{
                flask.handleReaction( reaction)
            }
        }
        
    }

}
