//
//  FlaskUtils.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif


public class Flask<D:AnyObject>:FlaskConcrete {
    
    weak var owner:D?
    
    public var reactor:FlaskReactorClosure<D>  = { owner,reaction in }
    
    required public init(_ owner:D){
        self.owner=owner
    }
    
    /// MARK: -
    
    override public func bind(){
        guard (self.owner) != nil else {
            return assertionFailure("a owner is required")
        }
        super.bind()
    }
    
    override func handleMutation(_ reaction:FlaskReaction){
        
        
        if let owner = self.owner {
            reactor(owner,reaction)
        }else{
            //dispose flask when the owner is no longer present
            FlaskReactorManager.removeFlaskReactor(self)
        }
    }
    
    override public func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class FlaskConcrete:FlaskAnyEquatable{
    
    var stores:[MoleculeConcrete]=[]
    var binded = false
    
    
    func bindMolecule(_ store:MoleculeConcrete){
        bindMolecules([store])
    }
    
    func bindMolecules(_ bindedMolecules:[MoleculeConcrete]){
        stores = bindedMolecules
        bind()
    }
    
    public func getOwner()->AnyObject?{
        return nil
    }
    
    public func bind(){
        
        assert(!binded,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!stores.isEmpty,"At least one store is required")
        
        binded = true
        
        for store in stores {
           
            { [weak self] in
                if let wself = self {
                    Lab.Dispatcher.bindFlaskReactor(store, flask: wself)
                }
            }()
            
            store.bindActions()
        }
        
        
    }
    
    public func unbind(_ explicit:Bool = true){
        
        if(explicit && !binded){
            assert(binded,"Not bounded. It's required  to balance bind/unbind calls")
        }
        
        if(!binded){return}
        binded = false
        
        for store in stores {
            { [weak self] in
                if let wself = self {
                    Lab.Dispatcher.unbindFlaskReactor(store, flask: wself)
                }
            }()
            
            store.unbindActions()
        }
    }
    
    ///
    func handleMutation(_ reaction:FlaskReaction){}
    
    @discardableResult public func mutate<T:MoleculeConcrete>(_ aMolecule:T, _ mutator:@escaping FlaskMutatorParams<T>)->FlaskConcrete{
        
        let store = self.store(aMolecule)
        store.mutate(mutator)
        
        return self
    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func store<T:MoleculeConcrete>(_ store:T)->T{
        
        let registered = stores.contains { (aMolecule) -> Bool in
            aMolecule === store
        }
        assert(registered,"Molecule instance is not binded to this flask")
        return store
    }

}


