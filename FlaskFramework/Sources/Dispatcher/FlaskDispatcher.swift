
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
    
    lazy var flaskRefs: Dictionary<String, Array<FlaskWeakRef<FlaskConcrete>>> = {
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
   
    func bindFlaskReactor(_ molecule:MoleculeConcrete, flask:FlaskConcrete) {
        
        let moleculeName = molecule.name()
        var moleculeFlaskReactorRefs = getMoleculeFlaskReactorRefs(moleculeName)
        
        let ref = FlaskWeakRef(value:flask)
        moleculeFlaskReactorRefs.append(ref)
        setMoleculeFlaskReactorRefs(moleculeName,moleculeFlaskReactorRefs)
        
    }
    
    func unbindFlaskReactor(_ molecule:MoleculeConcrete, flask:FlaskConcrete) {
        
        let moleculeName = molecule.name()
        let moleculeFlaskReactorRefs = getMoleculeFlaskReactorRefs(moleculeName)
        
        let moleculeFlaskReactorRefsFiltered = moleculeFlaskReactorRefs.filter { $0.value != flask }
        
        setMoleculeFlaskReactorRefs(moleculeName,moleculeFlaskReactorRefsFiltered)
       
    }
    
    func getMoleculeFlaskReactorRefs(_ moleculeName:String) -> Array<FlaskWeakRef<FlaskConcrete>>{
        
        if let flasks = self.flaskRefs[moleculeName] {
            return flasks
        }
        
        return Array<FlaskWeakRef<FlaskConcrete>>()
        
    }
    
    func setMoleculeFlaskReactorRefs(_ moleculeName:String,_ refs:Array<FlaskWeakRef<FlaskConcrete>>){
        
        self.flaskRefs[moleculeName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension FlaskDispatcher {
   
    func commitChange(_ reaction:FlaskReaction){
        
        let moleculeName = reaction.molecule.name()
        let moleculeFlaskReactorRefs = getMoleculeFlaskReactorRefs(moleculeName)
        
        for moleculeFlaskReactorRef in moleculeFlaskReactorRefs {
            if let flask = moleculeFlaskReactorRef.value{
                flask.handleMix( reaction)
            }
        }
        
    }

}
