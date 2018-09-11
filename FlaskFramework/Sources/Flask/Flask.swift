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
    
    override public func fill(){
        guard (self.owner) != nil else {
            return assertionFailure("a owner is required")
        }
        super.fill()
    }
    
    override public func empty(_ explicit:Bool = true){
        super.empty(explicit)
    }
    
    override func handleReaction(_ reaction:FlaskReaction){
        
        
        if let owner = self.owner {
            reactor(owner,reaction)
        }else{
            //dispose flask when the owner is no longer present
            LabFlaskManager.removeFlask(self)
        }
    }
    
    override public func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class FlaskConcrete:LabEquatable{
    
    var stores:[StoreConcrete]=[]
    var filled = false
    
    
    func defineStore(_ store:StoreConcrete){
        defineStores([store])
    }
    
    func defineStores(_ fillingStores:[StoreConcrete]){
        stores = fillingStores
        
    }
    
    public func getOwner()->AnyObject?{
        return nil
    }
    
    public func fill(){
        
        assert(!filled,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!stores.isEmpty,"At least one store is required")
        
        filled = true
        
        for store in stores {
           
            { [weak self] in
                if let wself = self {
                    Lab.mixer.fillFlask(store, flask: wself)
                }
            }()
            
            store.defineMixers()
        }
        
        
    }
    
    public func empty(_ explicit:Bool = true){
        
        if(explicit && !filled){
            assert(filled,"Not binded. It's required  to balance bind/unbind calls")
        }
        
        if(!filled){return}
        filled = false
        
        for store in stores {
            { [weak self] in
                if let wself = self {
                    Lab.mixer.emptyFlask(store, flask: wself)
                }
            }()
            
            store.undefineMixers()
        }
    }
    
    ///
    func handleReaction(_ reaction:FlaskReaction){}
    
//    @discardableResult public func mix<T:StoreConcrete>(_ aStore:T, _ mixer:@escaping MixParams<T>)->FlaskConcrete{
//        
//        let store = self.store(aStore)
//        store.mix(mixer)
//        
//        return self
//    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func store<T:StoreConcrete>(_ store:T)->T{
        
        let registered = stores.contains { (aStore) -> Bool in
            aStore === store
        }
        assert(registered,"Store instance is not filling to this flask")
        return store
    }

}


