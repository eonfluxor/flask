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

open class Molecule<T:Atoms,A:RawRepresentable> : MoleculeConcrete{
    
    typealias AtomsType = T
    
    var atomsSnapshot: LabDictType = [:]
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
        snapshotAtom()
    }
    
    //////////////////
    // MARK: - STATE ACTIONS

   
    
    public func mixerName(_ val:A)->String{
        return val.rawValue as! String
    }
    
    public func mix(_ enumVal:A, _ reaction: @escaping MoleculeMixer){
        mixer(mixerName(enumVal), reaction)
    }
    
    public override func lastAtomsDictionary() -> LabDictType{
        return atomsSnapshot
    }
    public override func atomsDictionary() -> LabDictType{
        return _atoms.toDictionary()
    }
    
    public func currentAtoms()->T{
        return _atoms
    }
    
    func setCurrentAtom(_ atoms:T){
        _atoms = atoms
    }
    
    /// PRIVATE
    
    override func snapshotAtom(){
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
    
    override func abortAtomTransaction(){
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
        return ((atom as? LabRef) != nil)
    }
    
    
    required public init(){
        initializeMetaClass()
    }
    
    func lastAtomsDictionary() -> LabDictType{
        return [:]
    }
    func atomsDictionary() -> LabDictType{
        return [:]
    }
    func name() -> String {
        return "Molecule\(self.self)"
    }
    
    open func defineMixers(){}
    open func undefineMixers(){}
    
    func snapshotAtom(){}
    
    func initializeMetaClass(){}
    func atomsTransaction(_ transaction:@escaping ()-> Bool){}
    func abortAtomTransaction(){}
    
    
}



public extension MoleculeConcrete {
  
    @discardableResult public func mixer(_ mixer:String, _ reaction: @escaping MoleculeMixer)->NSObjectProtocol{
        let weakRegistration={ [weak self] in
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(mixer), object: nil, queue: OperationQueue.main) { (notification) in
                
                let payload = notification.object
                var resolved = false
                var completed = true
                
                let react = {
                    resolved=true
                    self?.handleMix()
                }
                
                let abort = {
                    resolved=true
                    completed = false
                }
                
                self?.atomsTransaction({
                    reaction(payload,react,abort)
                    assert(resolved, "reaction closure must call `react` or `abort`")
                    return completed
                })
                
                
            }
            
        }
        return weakRegistration()
    }
    
    public func mix<T:MoleculeConcrete>(_ mixer:@escaping MixParams<T>){
        
        var resolved = false
        var completed = true
        
        let react = {
            resolved = true
            self.handleMix()
        }
        
        let abort = {
            resolved = true
            completed = false
        }
        
        atomsTransaction({
            mixer(self as! T, react, abort)
            assert(resolved, "mixer closure must call `react` or `abort`")
            return completed
        })
    }
    
}

extension MoleculeConcrete {
    
    func handleMix(){
        Lab.mixer.reactionQueue.addOperation { [weak self] in
            
            if self == nil { return }
            
            let reaction = FlaskReaction(self! as MoleculeConcrete)
            
            if( reaction.changed()){
                Lab.mixer.reactChange(reaction)
            }else{
                //log
            }
            self?.snapshotAtom()
        }
       
    }
    
}

public extension MoleculeConcrete {
    

    public func get(_ key:String) -> String{
        
        assertAtomKey(key)
        
        let atoms = self.atomsDictionary()
        return atoms[key] as! String
    }
    
    func assertAtomKey(_ key:String) {
        let atoms = self.atomsDictionary()
        assert(atoms.keys.contains(key),"Prop must be defined in atoms")
        
    }
    
}

