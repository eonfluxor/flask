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
    
    public func on(_ enumVal:A, _ reaction: @escaping BusMutation){
        on(actionName(enumVal), reaction)
    }
    
    public override func stateSnapshotDictionary() -> FluxDictType{
        return _stateSnapshot.toDictionary()
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
        
        pendingStateTransaction = context;
        //CAPTURE ORIGINAL STATE FOR ROLLBACK
        snapshotState()
        
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


open class StoreConcrete:Hashable {
    
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
    
    func stateSnapshotDictionary() -> FluxDictType{
        return [:]
    }
    func stateDictionary() -> FluxDictType{
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
    
    open func defineBusEvents(){}
    open func undefineBusEvents(){}
    
    func snapshotState(){}
    
    func initializeMetaClass(){}
    
    func beginStateTransaction(context:String,_ transaction:()->Void){}
    func abortStateTransaction(context:String){}
    func commitStateTransaction(context:String){}
    
    /////
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    public static func == (lhs: StoreConcrete, rhs: StoreConcrete) -> Bool {
        return lhs === rhs
    }
    
}


public extension StoreConcrete{
    public static func isInternalProp(_ state:String)->Bool{
        return state.starts(with: "_")
    }
    
    public static func isObjectRef(_ state:Any)->Bool{
        return ((state as? FluxRef) != nil)
    }
}


public extension StoreConcrete {
  
    public func on(_ event:String, _ reaction: @escaping BusMutation){
        let weakRegistration={ [weak self] in
            
            BusNotifier.addCallback(forEvent: event, object: self) { (notification) in
                
                
                let context = "Store.on(event:reaction:)"
                let payload = notification.payload
                
                let lock = payload?[BUS_LOCKED_BY] as? BusLock
                
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

