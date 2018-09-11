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
    
    public var reactor:ReactionClosure<D>  = { owner,reaction in }
    
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
    
    override public func unbind(_ explicit:Bool = true){
        super.unbind(explicit)
    }
    
    override func handleReaction(_ reaction:FlaskReaction){
        
        
        if let owner = self.owner {
            reactor(owner,reaction)
        }else{
            //dispose flask when the owner is no longer present
            FluxFlaskManager.removeFlask(self)
        }
    }
    
    override public func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class FlaskConcrete:FluxEquatable{
    
    var stores:[StoreConcrete]=[]
    var binded = false
    
    
    func defineStore(_ store:StoreConcrete){
        defineStores([store])
    }
    
    func defineStores(_ bindingStores:[StoreConcrete]){
        stores = bindingStores
        
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
                    Flux.bus.bindFlask(store, flask: wself)
                }
            }()
            
            store.defineBusEvents()
        }
        
        
    }
    
    public func unbind(_ explicit:Bool = true){
        
        if(explicit && !binded){
            assert(binded,"Not binded. It's required  to balance bind/unbind calls")
        }
        
        if(!binded){return}
        binded = false
        
        for store in stores {
            { [weak self] in
                if let wself = self {
                    Flux.bus.unbindFlask(store, flask: wself)
                }
            }()
            
            store.undefineBusEvents()
        }
    }
    
    ///
    func handleReaction(_ reaction:FlaskReaction){}
    
//    @discardableResult public mutation<T:StoreConcrete>(_ aStore:T, _ bus:@escaping MutationParams<T>)->FlaskConcrete{
//        
//        let store = self.store(aStore)
//        store.mutation(bus)
//        
//        return self
//    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func store<T:StoreConcrete>(_ store:T)->T{
        
        let registered = stores.contains { (aStore) -> Bool in
            aStore === store
        }
        assert(registered,"Store instance is not binding to this flask")
        return store
    }

}


