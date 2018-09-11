
//
//  mixer.swift
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

public class Mixer {
    
    //////////////////
    // MARK: - LOCKS
    
    var pauses:[MixerPause]=[]
    
    //////////////////
    // MARK: - OPERATION QUEUE
    
    let formulationQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    let formulationOnPauseQueue:OperationQueue = {
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
    
    lazy var flaskRefs: Dictionary<String, Array<LabWeakRef<FlaskConcrete>>> = {
        return Dictionary<String, Array<LabWeakRef<FlaskConcrete>>>()
    }();
    
    func pause()->MixerPause{
        return MixerPause(mixer:self)
    }
    
}
    
//////////////////
// MARK: - PUBLIC METHODS

extension Mixer {
    
    func formulate(_ mixer:String){
        formulate(mixer,payload:nil)
    }
    
    func formulate<T:RawRepresentable>(_ enumVal:T){
        formulate(enumVal,payload:nil)
    }
    
    func formulate<T:RawRepresentable>(_ enumVal:T, payload:[String:Any]?){
        let mixer = enumVal.rawValue as! String
        formulate(mixer,payload:payload)
    }
    
    func formulate(_ mixer:String, payload:[String:Any]?){
        enqueue(mixer,payload: payload)
    }
    
    
    
}

//////////////////
// MARK: - QUEUE

extension Mixer {
 
    func enqueue(_ mixer:String, payload:[String:Any]?){
        

        var queue = formulationQueue
        if (payload?[MIXER_PAUSED_BY]) != nil {
            queue = formulationOnPauseQueue
        }
        
        //TODO: log same mixer warning
        //TODO: log queue pauseed warning
//        assert( self.currentAction != mixer, "cannot call recursive mixer in infinite loop")
        
        queue.addOperation { [weak self, weak queue] in
            
            if let q = queue {
                assert( !q.isSuspended, "queue should not perform when suspended")
            }
            
            assert( self?.currentAction == .none, "cannot call during formulate")
            
            self?.currentAction = mixer
            NotificationCenter.default.post(
                name: NSNotification.Name(mixer),
                object: payload,
                userInfo: .none)
            self?.currentAction = .none
        }
    }
 
}

//////////////////
// MARK: - BINDINGS

extension Mixer {
   
    func fillFlask(_ molecule:MoleculeConcrete, flask:FlaskConcrete) {
        
        let moleculeName = molecule.name()
        var moleculeFlaskRefs = getMoleculeFlaskRefs(moleculeName)
        
        let ref = LabWeakRef(value:flask)
        moleculeFlaskRefs.append(ref)
        setMoleculeFlaskRefs(moleculeName,moleculeFlaskRefs)
        
    }
    
    func emptyFlask(_ molecule:MoleculeConcrete, flask:FlaskConcrete) {
        
        let moleculeName = molecule.name()
        let moleculeFlaskRefs = getMoleculeFlaskRefs(moleculeName)
        
        let moleculeFlaskRefsFiltered = moleculeFlaskRefs.filter { $0.value != flask }
        
        setMoleculeFlaskRefs(moleculeName,moleculeFlaskRefsFiltered)
       
    }
    
    func getMoleculeFlaskRefs(_ moleculeName:String) -> Array<LabWeakRef<FlaskConcrete>>{
        
        if let flasks = self.flaskRefs[moleculeName] {
            return flasks
        }
        
        return Array<LabWeakRef<FlaskConcrete>>()
        
    }
    
    func setMoleculeFlaskRefs(_ moleculeName:String,_ refs:Array<LabWeakRef<FlaskConcrete>>){
        
        self.flaskRefs[moleculeName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension Mixer {
   
    func reactChange(_ reaction:FlaskReaction){
        
        let moleculeName = reaction.molecule.name()
        let moleculeFlaskRefs = getMoleculeFlaskRefs(moleculeName)
        
        for moleculeFlaskRef in moleculeFlaskRefs {
            if let flask = moleculeFlaskRef.value{
                flask.handleReaction( reaction)
            }
        }
        
    }

}
