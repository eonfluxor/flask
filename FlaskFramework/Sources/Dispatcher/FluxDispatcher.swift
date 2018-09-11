
//
//  dispatcher.swift
//  SwiftyFlux
//
//  Created by hassan uriostegui on 8/28/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public class FluxDispatcher {
    
    //////////////////
    // MARK: - LOCKS
    
    var locks:[FluxLock]=[]
    
    //////////////////
    // MARK: - OPERATION QUEUE
    
    let dispatchQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    let dispatchLockedQueue:OperationQueue = {
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
    
    lazy var fluxRefs: Dictionary<String, Array<FluxWeakRef<FluxorConcrete>>> = {
        return Dictionary<String, Array<FluxWeakRef<FluxorConcrete>>>()
    }();
    
    func lock()->FluxLock{
        return FluxLock(dispatcher:self)
    }
    
}
    
//////////////////
// MARK: - PUBLIC METHODS

extension FluxDispatcher {
    
    func dispatch(_ action:String){
        dispatch(action,payload:nil)
    }
    
    func dispatch<T:RawRepresentable>(_ enumVal:T){
        dispatch(enumVal,payload:nil)
    }
    
    func dispatch<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let action = enumVal.rawValue as! String
        dispatch(action,payload:payload)
    }
    
    func dispatch(_ action:String, payload:[String:Any]?){
        queue(action,payload: payload)
    }
    
    
    
}

//////////////////
// MARK: - QUEUE

extension FluxDispatcher {
 
    func queue(_ action:String, payload:[String:Any]?){
        
        var queue = dispatchQueue
        if  ((payload?[FLUX_ACTION_SKIP_LOCKS]) != nil) {
            queue = dispatchLockedQueue
        }
        
        //TODO: log same action warning
        //TODO: log queue locked warning
//        assert( self.currentAction != action, "cannot call recursive action in infinite loop")
        
        queue.addOperation { [weak self, weak queue] in
            
            if let q = queue {
                assert( !q.isSuspended, "queue should not perform when suspended")
            }
            
            assert( self?.currentAction == .none, "cannot call during dispatch")
            
            self?.currentAction = action
            NotificationCenter.default.post(
                name: NSNotification.Name(action),
                object: payload,
                userInfo: .none)
            self?.currentAction = .none
        }
    }
 
}

//////////////////
// MARK: - BINDINGS

extension FluxDispatcher {
   
    func bindFluxor(_ store:FluxStoreConcrete, flux:FluxorConcrete) {
        
        let storeName = store.name()
        var storeFluxorRefs = getStoreFluxorRefs(storeName)
        
        let ref = FluxWeakRef(value:flux)
        storeFluxorRefs.append(ref)
        setStoreFluxorRefs(storeName,storeFluxorRefs)
        
    }
    
    func unbindFluxor(_ store:FluxStoreConcrete, flux:FluxorConcrete) {
        
        let storeName = store.name()
        let storeFluxorRefs = getStoreFluxorRefs(storeName)
        
        let storeFluxorRefsFiltered = storeFluxorRefs.filter { $0.value != flux }
        
        setStoreFluxorRefs(storeName,storeFluxorRefsFiltered)
       
    }
    
    func getStoreFluxorRefs(_ storeName:String) -> Array<FluxWeakRef<FluxorConcrete>>{
        
        if let fluxors = self.fluxRefs[storeName] {
            return fluxors
        }
        
        return Array<FluxWeakRef<FluxorConcrete>>()
        
    }
    
    func setStoreFluxorRefs(_ storeName:String,_ refs:Array<FluxWeakRef<FluxorConcrete>>){
        
        self.fluxRefs[storeName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension FluxDispatcher {
   
    func commitChange(_ reaction:FluxReaction){
        
        let storeName = reaction.store.name()
        let storeFluxorRefs = getStoreFluxorRefs(storeName)
        
        for storeFluxorRef in storeFluxorRefs {
            if let flux = storeFluxorRef.value{
                flux.handleMutation( reaction)
            }
        }
        
    }

}
