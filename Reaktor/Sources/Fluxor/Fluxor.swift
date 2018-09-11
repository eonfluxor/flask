//
//  FluxUtils.swift
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


public class Fluxor<D:AnyObject>:FluxorConcrete {
    
    weak var owner:D?
    
    var reactor:FluxorClosure<D>  = { owner,reaction in }
    
    required public init(_ owner:D){
        self.owner=owner
    }
    
    /// MARK: -
    
    override func bind(){
        guard (self.owner) != nil else {
            return assertionFailure("a owner is required")
        }
        super.bind()
    }
    
    override func handleMutation(_ reaction:FluxReaction){
        
        
        if let owner = self.owner {
            reactor(owner,reaction)
        }else{
            //dispose flux when the owner is no longer present
            FluxorManager.removeFluxor(self)
        }
    }
    
    override func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class FluxorConcrete:FluxAnyEquatable{
    
    var stores:[FluxStoreConcrete]=[]
    var binded = false
    
    
    func bindStore(_ store:FluxStoreConcrete){
        bindStores([store])
    }
    
    func bindStores(_ bindedStores:[FluxStoreConcrete]){
        stores = bindedStores
        bind()
    }
    
    func getOwner()->AnyObject?{
        return nil
    }
    
    func bind(){
        
        assert(!binded,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!stores.isEmpty,"At least one store is required")
        
        binded = true
        
        for store in stores {
           
            { [weak self] in
                if let wself = self {
                    Flux.Dispatcher.bindFluxor(store, flux: wself)
                }
            }()
            
            store.bindActions()
        }
        
        
    }
    
    func unbind(_ explicit:Bool = true){
        
        if(explicit && !binded){
            assert(binded,"Not bounded. It's required  to balance bind/unbind calls")
        }
        
        if(!binded){return}
        binded = false
        
        for store in stores {
            { [weak self] in
                if let wself = self {
                    Flux.Dispatcher.unbindFluxor(store, flux: wself)
                }
            }()
            
            store.unbindActions()
        }
    }
    
    ///
    func handleMutation(_ reaction:FluxReaction){}
    
    @discardableResult func mutate<T:FluxStoreConcrete>(_ aStore:T, _ mutator:@escaping FluxMutatorParams<T>)->FluxorConcrete{
        
        let store = self.store(aStore)
        store.mutate(mutator)
        
        return self
    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    func store<T:FluxStoreConcrete>(_ store:T)->T{
        
        let registered = stores.contains { (aStore) -> Bool in
            aStore === store
        }
        assert(registered,"Store instance is not binded to this flux")
        return store
    }

}


