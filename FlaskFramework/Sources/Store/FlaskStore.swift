//
//  MoleculeConcrete.swift
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

open class Molecule<T:MoleculeState,A:RawRepresentable> : MoleculeConcrete{
    
    typealias MoleculeStateType = T
    
    var atomsSnapshot: MoleculeStateDictionaryType = [:]
    private var _atoms: T = T()
    public var atoms:T = T()
   
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
    
    public func mixer(_ enumVal:A, _ reaction: @escaping MoleculeMutator){
        action(actionName(enumVal), reaction)
    }
    
    public override func lastStateDictionary() -> MoleculeStateDictionaryType{
        return atomsSnapshot
    }
    public override func atomsDictionary() -> MoleculeStateDictionaryType{
        return _atoms.toDictionary()
    }
    
    public func currentState()->T{
        return _atoms
    }
    
    func setCurrentState(_ atoms:T){
        _atoms = atoms
    }
    
    /// PRIVATE
    
    override func snapshotState(){
        self.atomsSnapshot = self.atomsDictionary()
        archiveIntent(_atoms)
    }
    

    override func atomsTransaction(_ transaction:@escaping ()-> Bool){
        transactonsQueue.addOperation { [weak self] in
            
            if self == nil {return}
            
            self!.atoms = self!._atoms
            
            if transaction() {
                self!._atoms = self!.atoms
            }else{
                self!.atoms = self!._atoms
            }
        }
        
    }
    
    override func abortStateTransaction(){
        transactonsQueue.addOperation { [weak self] in
            
            if self == nil {return}
            
            self!.atoms = self!._atoms
        }
    }
}




open class MoleculeConcrete {
    
    public static func isInternalProp(_ atom:String)->Bool{
        return atom.starts(with: "_")
    }
    
    public static func isObjectRef(_ atom:Any)->Bool{
        return ((atom as? FlaskRef) != nil)
    }
    
    
    required public init(){
        initializeMetaClass()
    }
    
    func lastStateDictionary() -> MoleculeStateDictionaryType{
        return [:]
    }
    func atomsDictionary() -> MoleculeStateDictionaryType{
        return [:]
    }
    func name() -> String {
        return "Molecule\(self.self)"
    }
    
    open func bindMixers(){}
    open func unbindMixers(){}
    
    func snapshotState(){}
    
    func initializeMetaClass(){}
    func atomsTransaction(_ transaction:@escaping ()-> Bool){}
    func abortStateTransaction(){}
    
    
}



public extension MoleculeConcrete {
  
    @discardableResult public func action(_ action:String, _ reaction: @escaping MoleculeMutator)->NSObjectProtocol{
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
                
                self?.atomsTransaction({
                    reaction(payload,commit,abort)
                    assert(resolved, "reaction closure must call `commit` or `abort`")
                    return completed
                })
                
                
            }
            
        }
        return weakRegistration()
    }
    
    public func mix<T:MoleculeConcrete>(_ mixer:@escaping FlaskMutatorParams<T>){
        
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
        
        atomsTransaction({
            mixer(self as! T, commit, abort)
            assert(resolved, "mixer closure must call `commit` or `abort`")
            return completed
        })
    }
    
}

extension MoleculeConcrete {
    
    func handleMutation(){
        Lab.Dispatcher.reactionQueue.addOperation { [weak self] in
            
            if self == nil { return }
            
            let reaction = FlaskReaction(self! as MoleculeConcrete)
            
            if( reaction.changed()){
                Lab.Dispatcher.commitChange(reaction)
            }else{
                //log
            }
            self?.snapshotState()
        }
       
    }
    
}

public extension MoleculeConcrete {
    

    public func get(_ key:String) -> String{
        
        assertStateKey(key)
        
        let atoms = self.atomsDictionary()
        return atoms[key] as! String
    }
    
    func assertStateKey(_ key:String) {
        let atoms = self.atomsDictionary()
        assert(atoms.keys.contains(key),"Prop must be defined in atoms")
        
    }
    
}

