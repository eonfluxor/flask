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

open class Substance<T:State,A:RawRepresentable> : SubstanceConcrete{
    
    typealias StateType = T
    
    var stateSnapshot: LabDictType = [:]
    private var _state: T = T()
    public var state:T = T()
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
        snapshotState()
    }
    
    //////////////////
    // MARK: - STATE ACTIONS

   
    
    public func mixerName(_ val:A)->String{
        return val.rawValue as! String
    }
    
    public func mixer(_ enumVal:A, _ reaction: @escaping SubstanceMixer){
        mixer(mixerName(enumVal), reaction)
    }
    
    public override func stateSnapshotDictionary() -> LabDictType{
        return stateSnapshot
    }
    public override func stateDictionary() -> LabDictType{
        return _state.toDictionary()
    }
    
    public func currentState()->T{
        return _state
    }
    
    func setCurrentState(_ state:T){
        _state = state
    }
    
    /// PRIVATE
    
    override func snapshotState(){
        self.stateSnapshot = self.stateDictionary()
        archiveIntent(_state)
    }
    

    override func stateTransaction(_ transaction:@escaping ()-> Bool){
        transactonsQueue.addOperation { [weak self] in
            
            if self == nil {return}
            
            self!.state = self!._state
            
            if transaction() {
                self!._state = self!.state
            }else{
                self!.state = self!._state
            }
        }
        
    }
    
    override func abortStateTransaction(){
        transactonsQueue.addOperation { [weak self] in
            
            if self == nil {return}
            
            self!.state = self!._state
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
    
    func stateSnapshotDictionary() -> LabDictType{
        return [:]
    }
    func stateDictionary() -> LabDictType{
        return [:]
    }
    func name() -> String {
        return "Substance\(self.self)"
    }
    
    open func defineMixers(){}
    open func undefineMixers(){}
    
    func snapshotState(){}
    
    func initializeMetaClass(){}
    func stateTransaction(_ transaction:@escaping ()-> Bool){}
    func abortStateTransaction(){}
    
    
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
                
                self?.stateTransaction({
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
            self?.snapshotState()
        }
       
    }
    
}

public extension SubstanceConcrete {
    

    public func get(_ key:String) -> String{
        
        assertStateKey(key)
        
        let state = self.stateDictionary()
        return state[key] as! String
    }
    
    func assertStateKey(_ key:String) {
        let state = self.stateDictionary()
        assert(state.keys.contains(key),"Prop must be defined in state")
        
    }
    
}

