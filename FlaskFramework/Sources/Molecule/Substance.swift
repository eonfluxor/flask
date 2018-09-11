//
//  SubstanceConcrete.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 8/28/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

open class Substance<T:States,A:RawRepresentable> : SubstanceConcrete{
    
    typealias StatesType = T
    
    var statesSnapshot: LabDictType = [:]
    private var _states: T = T()
    public var states:T = T()
    //////////////////
    // MARK: - TRANSACTIONS QUEUE
    
    let transactonsQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    let archiveQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount=1
        return queue
    }()
    
    //////////////////
    // MARK: - INITIALIZE
    
    override public func initializeMetaClass() {
        unarchiveIntent()
        snapshotStates()
    }
    
    //////////////////
    // MARK: - STATE ACTIONS

   
    
    public func mixerName(_ val:A)->String{
        return val.rawValue as! String
    }
    
    public func mixer(_ enumVal:A, _ reaction: @escaping SubstanceMixer){
        mixer(mixerName(enumVal), reaction)
    }
    
    public override func statesSnapshotDictionary() -> LabDictType{
        return statesSnapshot
    }
    public override func statesDictionary() -> LabDictType{
        return _states.toDictionary()
    }
    
    public func currentStates()->T{
        return _states
    }
    
    func setCurrentState(_ states:T){
        _states = states
    }
    
    /// PRIVATE
    
    override func snapshotStates(){
        self.statesSnapshot = self.statesDictionary()
        archiveIntent(_states)
    }
    

    override func statesTransaction(_ transaction:@escaping ()-> Bool){
        transactonsQueue.addOperation { [weak self] in
            
            if self == nil {return}
            
            self!.states = self!._states
            
            if transaction() {
                self!._states = self!.states
            }else{
                self!.states = self!._states
            }
        }
        
    }
    
    override func abortStatesTransaction(){
        transactonsQueue.addOperation { [weak self] in
            
            if self == nil {return}
            
            self!.states = self!._states
        }
    }
}




open class SubstanceConcrete {
    
    public static func isInternalProp(_ state:String)->Bool{
        return state.starts(with: "_")
    }
    
    public static func isObjectRef(_ state:Any)->Bool{
        return ((state as? LabRef) != nil)
    }
    
    
    required public init(){
        initializeMetaClass()
    }
    
    func statesSnapshotDictionary() -> LabDictType{
        return [:]
    }
    func statesDictionary() -> LabDictType{
        return [:]
    }
    func name() -> String {
        return "Substance\(self.self)"
    }
    
    open func defineMixers(){}
    open func undefineMixers(){}
    
    func snapshotStates(){}
    
    func initializeMetaClass(){}
    func statesTransaction(_ transaction:@escaping ()-> Bool){}
    func abortStatesTransaction(){}
    
    
}



public extension SubstanceConcrete {
  
    @discardableResult public func mixer(_ mixer:String, _ reaction: @escaping SubstanceMixer)->NSObjectProtocol{
        let weakRegistration={ [weak self] in
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(mixer), object: nil, queue: OperationQueue.main) { (notification) in
                
                let payload = notification.object as? [String:Any]
                
                let pause = payload?[MIXER_PAUSED_BY] as? MixerPause
                
                var resolved = false
                var completed = true
                
                let react = {
                    resolved=true
                    self?.handleMix(pause)
                }
                
                let abort = {
                    resolved=true
                    completed = false
                }
                
                self?.statesTransaction({
                    reaction(payload,react,abort)
                    assert(resolved, "reaction closure must call `react` or `abort`")
                    return completed
                })
                
                
            }
            
        }
        return weakRegistration()
    }
    
}

extension SubstanceConcrete {
    
    func handleMix(_ mixerPause: MixerPause? = nil){
        Lab.mixer.reactionQueue.addOperation { [weak self] in
            
            if self == nil { return }
            
            let reaction = FlaskReaction(self! as SubstanceConcrete)
            reaction.onPause = mixerPause
            
            if( reaction.changed()){
                Lab.mixer.reactChange(reaction)
            }else{
                //log
            }
            self?.snapshotStates()
        }
       
    }
    
}

public extension SubstanceConcrete {
    

    public func get(_ key:String) -> String{
        
        assertStateKey(key)
        
        let states = self.statesDictionary()
        return states[key] as! String
    }
    
    func assertStateKey(_ key:String) {
        let states = self.statesDictionary()
        assert(states.keys.contains(key),"Prop must be defined in states")
        
    }
    
}

