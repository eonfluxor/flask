
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
   
    func fillFlask(_ substance:SubstanceConcrete, flask:FlaskConcrete) {
        
        let substanceName = substance.name()
        var substanceFlaskRefs = getSubstanceFlaskRefs(substanceName)
        
        let ref = LabWeakRef(value:flask)
        substanceFlaskRefs.append(ref)
        setSubstanceFlaskRefs(substanceName,substanceFlaskRefs)
        
    }
    
    func emptyFlask(_ substance:SubstanceConcrete, flask:FlaskConcrete) {
        
        let substanceName = substance.name()
        let substanceFlaskRefs = getSubstanceFlaskRefs(substanceName)
        
        let substanceFlaskRefsFiltered = substanceFlaskRefs.filter { $0.value != flask }
        
        setSubstanceFlaskRefs(substanceName,substanceFlaskRefsFiltered)
       
    }
    
    func getSubstanceFlaskRefs(_ substanceName:String) -> Array<LabWeakRef<FlaskConcrete>>{
        
        if let flasks = self.flaskRefs[substanceName] {
            return flasks
        }
        
        return Array<LabWeakRef<FlaskConcrete>>()
        
    }
    
    func setSubstanceFlaskRefs(_ substanceName:String,_ refs:Array<LabWeakRef<FlaskConcrete>>){
        
        self.flaskRefs[substanceName] = refs
    }
}

//////////////////
// MARK: - MUTATIONS

extension Mixer {
   
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
