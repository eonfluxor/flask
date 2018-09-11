//
//  StoreConcrete.swift
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

open class Store<T:State,A:RawRepresentable> : StoreConcrete{
    
    typealias StateType = T
    
    var stateSnapshot: FluxDictType = [:]
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
    
    public func on(_ enumVal:A, _ reaction: @escaping StoreBus){
        bus(actionName(enumVal), reaction)
    }
    
    public override func stateSnapshotDictionary() -> FluxDictType{
        return stateSnapshot
    }
    public override func stateDictionary() -> FluxDictType{
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




open class StoreConcrete {
    
    public static func isInternalProp(_ state:String)->Bool{
        return state.starts(with: "_")
    }
    
    public static func isObjectRef(_ state:Any)->Bool{
        return ((state as? FluxRef) != nil)
    }
    
    
    required public init(){
        initializeMetaClass()
    }
    
    func stateSnapshotDictionary() -> FluxDictType{
        return [:]
    }
    func stateDictionary() -> FluxDictType{
        return [:]
    }
    func name() -> String {
        return "Store\(self.self)"
    }
    
    open func defineBusEvents(){}
    open func undefineBusEvents(){}
    
    func snapshotState(){}
    
    func initializeMetaClass(){}
    func stateTransaction(_ transaction:@escaping ()-> Bool){}
    func abortStateTransaction(){}
    
    
}



public extension StoreConcrete {
  
    @discardableResult public func bus(_ bus:String, _ reaction: @escaping StoreBus)->NSObjectProtocol{
        let weakRegistration={ [weak self] in
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(bus), object: nil, queue: OperationQueue.main) { (notification) in
                
                let payload = notification.object as? [String:Any]
                
                let lock = payload?[BUS_LOCKED_BY] as? BusLock
                
                var resolved = false
                var completed = true
                
                let react = {
                    resolved=true
                    self?.handleMutation(lock)
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

extension StoreConcrete {
    
    func handleMutation(_ busLock: BusLock? = nil){
        Flux.bus.reactionQueue.addOperation { [weak self] in
            
            if self == nil { return }
            
            let reaction = FlaskReaction(self! as StoreConcrete)
            reaction.onLock = busLock
            
            if( reaction.changed()){
                Flux.bus.reactChange(reaction)
            }else{
                //log
            }
            self?.snapshotState()
        }
       
    }
    
}

public extension StoreConcrete {
    

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

