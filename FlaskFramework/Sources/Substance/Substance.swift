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
    
    private var _stateSnapshot: T = T()
    private var _state: T = T()
    public var state:T = T()
    
    private var pendingStateTransaction:String?
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
    
    public func mix(_ enumVal:A, _ reaction: @escaping FluxMutation){
        mix(actionName(enumVal), reaction)
    }
    
    public override func stateSnapshotDictionary() -> FlaskDictType{
        return _stateSnapshot.toDictionary()
    }
    public override func stateDictionary() -> FlaskDictType{
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
        self._stateSnapshot = self._state
        archiveIntent()
    }
    
    func stateFromSnapshot()->T{
        return self._stateSnapshot
    }

    
    override func beginStateTransaction(context:String,_ transaction:()->Void){
        
        if let lastContext = pendingStateTransaction{
            assert(lastContext == context,"please resolve `commit|abort` transaction \(String(describing: pendingStateTransaction)) first")
        } else{
            assert(pendingStateTransaction == nil, "please resolve `commit|abort` transaction \(String(describing: pendingStateTransaction)) first")
        }
        
        if pendingStateTransaction == nil ||
            pendingStateTransaction != context{
              snapshotState()
        }
        pendingStateTransaction = context;
        //CAPTURE ORIGINAL STATE FOR ROLLBACK
      
        
        //OPTIMISCALLY MUTATE THE STATE
        state = _state
        transaction()
        _state = state
    }
    
    override func commitStateTransaction(context:String){
        
        assert(pendingStateTransaction == context,"Must balance a call to `start` with `commit|abort` stateTransaction for context \(String(describing: pendingStateTransaction))")
        pendingStateTransaction = nil
        _state = state
    }
    override func abortStateTransaction(context:String){
        
        assert(self.pendingStateTransaction == context,"Must balance a call to `start` with `commit|abort` stateTransaction for context \(String(describing: pendingStateTransaction))")
        pendingStateTransaction = nil
        
        state = stateFromSnapshot()
    }
}


open class SubstanceConcrete:Hashable {
    
    var _namePrefix:String?
    var _nameSuffix:String?
    var _name:String?
    
    required  public init(name aName:String){
        name(as:aName)
        initializeMetaClass()
    }
    
    required  public init(){
        initializeMetaClass()
    }
    
    func stateSnapshotDictionary() -> FlaskDictType{
        return [:]
    }
    func stateDictionary() -> FlaskDictType{
        return [:]
    }
    func name() -> String {
        let prefix = _namePrefix ?? "Flx"
        let name = _name ?? "Str"
        let suffix = _nameSuffix ?? ".\(self.self)"
        
        return "\(prefix)\(name)\(suffix)"
    }
    
    func name(as aName:String){
        _name = aName
        _namePrefix = ""
        _nameSuffix = ""
    }
    
    func name(prefix:String){
        _namePrefix = prefix
    }
    
    func name(suffix:String){
         _nameSuffix = suffix
    }
    
    open func defineMixers(){}
    open func undefineMixers(){}
    
    func snapshotState(){}
    
    func initializeMetaClass(){}
    
    func beginStateTransaction(context:String,_ transaction:()->Void){}
    func abortStateTransaction(context:String){}
    func commitStateTransaction(context:String){}
    
    /////
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    public static func == (lhs: SubstanceConcrete, rhs: SubstanceConcrete) -> Bool {
        return lhs === rhs
    }
    
}


public extension SubstanceConcrete{
    public static func isInternalProp(_ state:String)->Bool{
        return state.starts(with: "_")
    }
    
    public static func isObjectRef(_ state:Any)->Bool{
        return ((state as? FlaskNSRef) != nil)
    }
}


public extension SubstanceConcrete {
  
    public func mix(_ mixer:String, _ reaction: @escaping FluxMutation){
        let weakRegistration={ [weak self] in
            
            FluxNotifier.addCallback(forMixer: mixer, object: self) { (notification) in
                
                
                let context = "Substance.on(mixer:reaction:)"
                let payload = notification.payload
                
                let lock = payload?[BUS_LOCKED_BY] as? FluxLock
                
                var resolved = false
                
                let react = {
                    resolved=true
                    self?.commitStateTransaction(context:context)
                    self?.reduceAndReact(lock)
                }
                
                let abort = {
                    self?.abortStateTransaction(context:context)
                    resolved=true
                }
                
                self?.beginStateTransaction(context:context){
                     reaction(payload,react,abort)
                }
               
                if self != nil {
                    assert(resolved, "reaction closure must call `react` or `abort`")
                }
                
            }
            
        }
        weakRegistration()
    }
    
}

extension SubstanceConcrete {
    
    func reduceAndReact(_ busLock: FluxLock? = nil){
        
        let reaction = FlaskReaction(self as SubstanceConcrete)
        reaction.onLock = busLock
        
        if( reaction.changed()){
            Flask.bus.reactChange(reaction)
        }else{
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

