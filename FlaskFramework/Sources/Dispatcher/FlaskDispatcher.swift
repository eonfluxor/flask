
//
//  dispatcher.swift
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

public class FlaskDispatcher {
    
    //////////////////
    // MARK: - LOCKS
    
    var locks:[FlaskLock]=[]
    
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
    
    lazy var fluxRefs: Dictionary<String, Array<FlaskWeakRef<FlaskConcrete>>> = {
        return Dictionary<String, Array<FlaskWeakRef<FlaskConcrete>>>()
    }();
    
    func lock()->FlaskLock{
        return FlaskLock(dispatcher:self)
    }
    
}
    
//////////////////
// MARK: - PUBLIC METHODS

extension FlaskDispatcher {
    
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

extension FlaskDispatcher {
 
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

extension FlaskDispatcher {
   
    func bindFlaskReactor(_ store:MoleculeConcrete, flux:FlaskConcrete) {
        
        let storeName = store.name()
        var storeFlaskReactorRefs = getMoleculeFlaskReactorRefs(storeName)
        
        let ref = FlaskWeakRef(value:flux)
        storeFlaskReactorRefs.append(ref)
        setMoleculeFlaskReactorRefs(storeName,storeFlaskReactorRefs)
        
    }
    
    func unbindFlaskReactor(_ store:MoleculeConcrete, flux:FlaskConcrete) {
        
        let storeName = store.name()
        let storeFlaskReactorRefs = getMoleculeFlaskReactorRefs(storeName)
        
        let storeFlaskReactorRefsFiltered = storeFlaskReactorRefs.filter { $0.value != flux }
        
        setMoleculeFlaskReactorRefs(storeName,storeFlaskReactorRefsFiltered)
       
    }
    
    func getMoleculeFlaskReactorRefs(_ storeName:String) -> Array<FlaskWeakRef<FlaskConcrete>>{
        
        if let fluxors = self.fluxRefs[storeName] {
            return fluxors
        }
        
        return Array<FlaskWeakRef<FlaskConcrete>>()
        
    }
    
    func setMoleculeFlaskReactorRefs(_ storeName:String,_ refs:Array<FlaskWeakRef<FlaskConcrete>>){
        
        self.fluxRefs[storeName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension FlaskDispatcher {
   
    func commitChange(_ reaction:FlaskReaction){
        
        let storeName = reaction.store.name()
        let storeFlaskReactorRefs = getMoleculeFlaskReactorRefs(storeName)
        
        for storeFlaskReactorRef in storeFlaskReactorRefs {
            if let flux = storeFlaskReactorRef.value{
                flux.handleMutation( reaction)
            }
        }
        
    }

}
