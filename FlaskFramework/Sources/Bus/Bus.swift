
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
    
//    let reactionQueue:OperationQueue = {
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount=1
//        return queue
//    }()
    
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
    
    func dispatch<T:RawRepresentable>(_ enumVal:T, payload:BusPayload? = nil){
        let bus = enumVal.rawValue as! String
        dispatch(bus,payload:payload)
    }
    
    func dispatch(_ bus:String, payload:BusPayload? = nil ){
        enqueue(bus,payload: payload)
    }
    
}

//////////////////
// MARK: - QUEUE

extension Bus {
 
    func enqueue(_ event:String, payload:BusPayload?){
        
        if (payload?[BUS_LOCKED_BY]) == nil {
            dispatchInBusQueue(event,payload:payload)
        }else{
            dispatchInLockQueue(event,payload:payload)
        }
        
    }
    
    func dispatchInBusQueue(_ event:String, payload:BusPayload?){
        
        let completed = { [weak self] in
            if let me = self{
                me.applyLocks()
            }
        }
        
        busQueue.addOperation { [weak self] in
            
          
//            assert( !(self?.busQueue.isSuspended)!, "queue should not perform when suspended")
          
            
            assert( self?.currentEvent == .none, "cannot call during mix")
            self?.currentEvent = event
            
            BusNotifier.postNotification(forEvent: event,
                                         payload: payload,
                                         completion: completed)
            
            
            self?.currentEvent = .none
            
        }
        
        busQueue.isSuspended = true
    }
    
    func dispatchInLockQueue(_ event:String, payload:BusPayload?){
        
        busOnLockQueue.addOperation {
            BusNotifier.postNotification(forEvent: event,
                                         payload: payload)
            
        }
    }
 
}



//////////////////
// MARK: - BINDINGS

extension Bus {
   
    func bindFlask(_ store:StoreConcrete, flask:FlaskConcrete) {
        
        let storeName = store.name()
        var storeFlaskRefs = getStoreFlaskRefs(storeName)
        
        let ref = FluxWeakRef(value:flask)
        storeFlaskRefs.append(ref)
        setStoreFlaskRefs(storeName,storeFlaskRefs)
        
    }
    
    func unbindFlask(_ store:StoreConcrete, flask:FlaskConcrete) {
        
        let storeName = store.name()
        let storeFlaskRefs = getStoreFlaskRefs(storeName)
        
        let storeFlaskRefsFiltered = storeFlaskRefs.filter { $0.value != flask }
        
        setStoreFlaskRefs(storeName,storeFlaskRefsFiltered)
       
    }
    
    func getStoreFlaskRefs(_ storeName:String) -> Array<FluxWeakRef<FlaskConcrete>>{
        
        if let flasks = self.flaskRefs[storeName] {
            return flasks
        }
        
        return Array<FluxWeakRef<FlaskConcrete>>()
        
    }
    
    func setStoreFlaskRefs(_ storeName:String,_ refs:Array<FluxWeakRef<FlaskConcrete>>){
        
        self.flaskRefs[storeName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension Bus {
   
    func reactChange(_ reaction:FlaskReaction){
        
        let storeName = reaction.store.name()
        let storeFlaskRefs = getStoreFlaskRefs(storeName)
        
        for storeFlaskRef in storeFlaskRefs {
            if let flask = storeFlaskRef.value{
                flask.handleReaction( reaction)
            }
        }
        
    }

}
