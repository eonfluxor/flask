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
    
    private var _finalStateSnapshot: T = T()
    
    private var _finalState: T = T()
    public var finalState:T{
        get{
            assert(pendingStateTransaction == nil, "Use `finalState` instead. `state` is only accesible during `Flask.mix` or `Substance.mixer` transactions")
            return _finalState
        }
        set(newState){
            assert(pendingStateTransaction == nil, "`state` is only accesible during `Flask.mix` or `Substance.mixer` transactions")
            _finalState = newState
        }
    }
    
    
    public var _mixingState:T = T()
    public var mixState:T{
        get{
            assert(pendingStateTransaction != nil, "Use `finalState` instead. `state` is only accesible during `Flask.mix` or `Substance.mixer` transactions")
            return _mixingState
        }
        set(newState){
            assert(pendingStateTransaction != nil, "`state` is only accesible during `Flask.mix` or `Substance.mixer` transactions")
            _mixingState = newState
        }
    }
    
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
    
    public func define(mix enumVal:A, _ reaction: @escaping FluxMutation){
        define( mix: actionName(enumVal), reaction)
    }
    
    public override func stateSnapshotDictionary() -> FlaskDictType{
        return _finalStateSnapshot.toDictionary()
    }
    public override func stateDictionary() -> FlaskDictType{
        return _finalState.toDictionary()
    }
    
    
   
    
    /// PRIVATE
    
    override func snapshotState(){
        self._finalStateSnapshot = self._finalState
        archiveIntent()
    }
    
    func stateFromSnapshot()->T{
        return self._finalStateSnapshot
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
        mixState = _finalState
        transaction()
        
        if pendingStateTransaction != nil{
            _finalState = mixState
        }
    }
    
    override func commitStateTransaction(context:String){
        
        assert(pendingStateTransaction == context,"Must balance a call to `start` with `commit|abort` stateTransaction for context \(String(describing: pendingStateTransaction))")

        _finalState = mixState
        pendingStateTransaction = nil
    }
    override func abortStateTransaction(context:String){
        
        assert(self.pendingStateTransaction == context,"Must balance a call to `start` with `commit|abort` stateTransaction for context \(String(describing: pendingStateTransaction))")
        
        mixState = stateFromSnapshot()
        pendingStateTransaction = nil
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
  
    public func define(mix mixer:String, _ reaction: @escaping FluxMutation){
        let weakRegistration={ [weak self] in
            
            FluxNotifier.addCallback(forMixer: mixer, object: self) { (notification) in
                
                var resolved = false
                
                defer{
                    if self != nil {
                        assert(resolved, "reaction closure must call `react` or `abort`")
                    }
                }
                
                let context = "Substance.on(mixer:reaction:)"
                let payload = notification.payload
                
                let lock = payload?[BUS_LOCKED_BY] as? FluxLock
                
                let react = {
                    self?.commitStateTransaction(context:context)
                    self?.reduceAndReact(lock)
                    resolved=true
                }
                
                let abort = {
                    self?.abortStateTransaction(context:context)
                    resolved=true
                }
                
                self?.beginStateTransaction(context:context){
                     reaction(payload,react,abort)
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

