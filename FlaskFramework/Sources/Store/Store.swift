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
    
    public func on(_ enumVal:A, _ reaction: @escaping BusMutation){
        on(actionName(enumVal), reaction)
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
        archiveIntent()
    }
    

    override func stateTransaction(_ transaction:@escaping ()-> Bool){
        
       startStateTransaction()
        
        if transaction() {
            commitStateTransaction()
        }else{
            abortStateTransaction()
        }
        
    }
    override func startStateTransaction(){
        state = _state
    }
    override func commitStateTransaction(){
        snapshotState()
        _state = state
    }
    override func abortStateTransaction(){
        state = _state
    }
    override func continueStateTransaction(){
         _state = state
    }
}




open class StoreConcrete:NSObject {
    
  
    
    
    public static func isInternalProp(_ state:String)->Bool{
        return state.starts(with: "_")
    }
    
    public static func isObjectRef(_ state:Any)->Bool{
        return ((state as? FluxRef) != nil)
    }
    
    
    required public override init(){
        super.init()
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
  
    func startStateTransaction(){}
    func abortStateTransaction(){}
    func commitStateTransaction(){}
    func continueStateTransaction(){}
    
}



public extension StoreConcrete {
  
    public func on(_ event:String, _ reaction: @escaping BusMutation){
        let weakRegistration={ [weak self] in
            
            BusNotifier.addCallback(forEvent: event, object: self) { (notification) in
                
                
                let payload = notification.payload
                
                let lock = payload?[BUS_LOCKED_BY] as? BusLock
                
                var resolved = false
                
                let react = {
                    resolved=true
                    self?.commitStateTransaction()
                    self?.reduceAndReact(lock)
                }
                
                let abort = {
                    self?.abortStateTransaction()
                    resolved=true
                }
                
                self?.startStateTransaction()
                reaction(payload,react,abort)
                assert(resolved, "reaction closure must call `react` or `abort`")
      
                
            }
            
        }
        weakRegistration()
    }
    
}

extension StoreConcrete {
    
    func reduceAndReact(_ busLock: BusLock? = nil){
        
        let reaction = FlaskReaction(self as StoreConcrete)
        reaction.onLock = busLock
        
        if( reaction.changed()){
            Flux.bus.reactChange(reaction)
        }else{
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

