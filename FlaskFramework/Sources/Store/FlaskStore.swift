//
//  FlaskStoreConcrete.swift
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

open class FlaskStore<A:RawRepresentable,T:FlaskState > : FlaskStoreConcrete{
    
    typealias FlaskStateType = T
    
    var stateSnapshot: FlaskStateDictionaryType = [:]
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

   
    
    public func actionName(_ val:A)->String{
        return val.rawValue as! String
    }
    
    public func mutator(_ enumVal:A, _ reaction: @escaping FlaskStoreMutator){
        action(actionName(enumVal), reaction)
    }
    
    public override func lastStateDictionary() -> FlaskStateDictionaryType{
        return stateSnapshot
    }
    public override func stateDictionary() -> FlaskStateDictionaryType{
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




open class FlaskStoreConcrete {
    
    public static func isInternalProp(_ prop:String)->Bool{
        return prop.starts(with: "_")
    }
    
    public static func isObjectRef(_ prop:Any)->Bool{
        return ((prop as? FlaskRef) != nil)
    }
    
    
    required public init(){
        initializeMetaClass()
    }
    
    func lastStateDictionary() -> FlaskStateDictionaryType{
        return [:]
    }
    func stateDictionary() -> FlaskStateDictionaryType{
        return [:]
    }
    func name() -> String {
        return "Store\(self.self)"
    }
    
    open func bindActions(){}
    open func unbindActions(){}
    
    func snapshotState(){}
    
    func initializeMetaClass(){}
    func stateTransaction(_ transaction:@escaping ()-> Bool){}
    func abortStateTransaction(){}
    
    
}



public extension FlaskStoreConcrete {
  
    @discardableResult public func action(_ action:String, _ reaction: @escaping FlaskStoreMutator)->NSObjectProtocol{
        let weakRegistration={ [weak self] in
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(action), object: nil, queue: OperationQueue.main) { (notification) in
                
                let payload = notification.object
                var resolved = false
                var completed = true
                
                let commit = {
                    resolved=true
                    self?.handleMutation()
                }
                
                let abort = {
                    resolved=true
                    completed = false
                }
                
                self?.stateTransaction({
                    reaction(payload,commit,abort)
                    assert(resolved, "reaction closure must call `commit` or `abort`")
                    return completed
                })
                
                
            }
            
        }
        return weakRegistration()
    }
    
    public func mutate<T:FlaskStoreConcrete>(_ mutator:@escaping FlaskMutatorParams<T>){
        
        var resolved = false
        var completed = true
        
        let commit = {
            resolved = true
            self.handleMutation()
        }
        
        let abort = {
            resolved = true
            completed = false
        }
        
        stateTransaction({
            mutator(self as! T, commit, abort)
            assert(resolved, "mutator closure must call `commit` or `abort`")
            return completed
        })
    }
    
}

extension FlaskStoreConcrete {
    
    func handleMutation(){
        Flask.Dispatcher.reactionQueue.addOperation { [weak self] in
            
            if self == nil { return }
            
            let reaction = FlaskReaction(self! as FlaskStoreConcrete)
            
            if( reaction.changed()){
                Flask.Dispatcher.commitChange(reaction)
            }else{
                //log
            }
            self?.snapshotState()
        }
       
    }
    
}

public extension FlaskStoreConcrete {
    

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

