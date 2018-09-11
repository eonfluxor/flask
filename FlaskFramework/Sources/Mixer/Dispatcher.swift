
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
    
    var pauses:[BusPause]=[]
    
    //////////////////
    // MARK: - OPERATION QUEUE
    
    let busQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    let busOnPauseQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    let reactionQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    //////////////////
    // MARK: - OPTIONALS
    
    var currentAction: String?
    
    //////////////////
    // MARK: - LAZY
    
    lazy var flaskRefs: Dictionary<String, Array<FluxWeakRef<FlaskConcrete>>> = {
        return Dictionary<String, Array<FluxWeakRef<FlaskConcrete>>>()
    }();
    
    func pause()->BusPause{
        return BusPause(bus:self)
    }
    
}
    
//////////////////
// MARK: - PUBLIC METHODS

extension Bus {
    
    func transmute(_ bus:String){
        transmute(bus,payload:nil)
    }
    
    func transmute<T:RawRepresentable>(_ enumVal:T){
        transmute(enumVal,payload:nil)
    }
    
    func transmute<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let bus = enumVal.rawValue as! String
        transmute(bus,payload:payload)
    }
    
    func transmute(_ bus:String, payload:[String:Any]?){
        enqueue(bus,payload: payload)
    }
    
    
    
}

//////////////////
// MARK: - QUEUE

extension Bus {
 
    func enqueue(_ bus:String, payload:[String:Any]?){
        

        var queue = busQueue
        if (payload?[BUS_PAUSED_BY]) != nil {
            queue = busOnPauseQueue
        }
        
        //TODO: log same bus warning
        //TODO: log queue pauseed warning
//        assert( self.currentAction != bus, "cannot call recursive bus in infinite loop")
        
        queue.addOperation { [weak self, weak queue] in
            
            if let q = queue {
                assert( !q.isSuspended, "queue should not perform when suspended")
            }
            
            assert( self?.currentAction == .none, "cannot call during mix")
            
            self?.currentAction = bus
            NotificationCenter.default.post(
                name: NSNotification.Name(bus),
                object: payload,
                userInfo: .none)
            self?.currentAction = .none
        }
    }
 
}

//////////////////
// MARK: - BINDINGS

extension Bus {
   
    func fillFlask(_ store:StoreConcrete, flask:FlaskConcrete) {
        
        let storeName = store.name()
        var storeFlaskRefs = getStoreFlaskRefs(storeName)
        
        let ref = FluxWeakRef(value:flask)
        storeFlaskRefs.append(ref)
        setStoreFlaskRefs(storeName,storeFlaskRefs)
        
    }
    
    func emptyFlask(_ store:StoreConcrete, flask:FlaskConcrete) {
        
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
