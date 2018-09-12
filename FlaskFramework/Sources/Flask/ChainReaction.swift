//
//  FlaskChain.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public class ChainReaction{
    
    let flask:FlaskConcrete
    var _react:(_ stores:[StoreConcrete])->Void
    let _abort:()->Void
    
    init(flask:FlaskConcrete,react:@escaping (_ stores:[StoreConcrete])->Void,abort:@escaping ()->Void) {
        self.flask = flask
        self._react = react
        self._abort = abort
    }
    
    public func abort(){
        abort()
    }
    
    public func react(){
        andReact()
    }
    public func andReact(){
        let stores:[StoreConcrete] = []
        _react(stores)
    }
    
    public func andAbort(){
        abort()
    }
    
    public func andMutate<T:StoreConcrete>(_ aStore:T, _ mutation:@escaping(_ store:T) -> Void)->ChainReaction{
        return mutate(aStore, mutation)
    }
    
    public func mutate<T:StoreConcrete>(_ aStore:T, _ mutation:@escaping (_ store:T) -> Void)->ChainReaction{
        
        let store = flask.store(aStore)
        
        let chainReact = _react
        _react = { (chainedStores) in
            
            var chainedStoresMut = chainedStores
            chainedStoresMut.append(store)
            chainReact(chainedStoresMut)
        }
        
        Flux.bus.performInBusQueue {
            store.startStateTransaction()
            mutation(store)
        }
        
        let chain = ChainReaction(flask:flask, react:_react, abort:_abort)
        return chain
    }
    
}

public extension FlaskConcrete{
    
    public func toMutate<T:StoreConcrete>(_ aStore:T, _ mutation:@escaping(_ store:T) -> Void)->ChainReaction{
        return mutate(aStore, mutation)
    }
    
    public func mutate<T:StoreConcrete>(_ aStore:T, _ mutation:@escaping(_ store:T) -> Void)->ChainReaction{
        
        let store = self.store(aStore)
        
        let  react:(_ chainedStores:[StoreConcrete])->Void = {  (chainedStores)  in
            
            var chainedStoresMut = chainedStores
            chainedStoresMut.append(store)
            
            let uniqueStores = Array(Set<StoreConcrete>(chainedStoresMut))
            
            assert(chainedStoresMut.count == uniqueStores.count, "Concatenate same store mutations in a single closure.")
            
            for store in uniqueStores{
                Flux.bus.performInBusQueue {
                    store.commitStateTransaction()
                    store.reduceAndReact()
                }
            }
        }
        
        let abort = {
            [weak self] in
            if let stores = self?.stores {
                for store in stores{
                     Flux.bus.performInBusQueue {
                        store.abortStateTransaction();
                    }
                }
            }
        }
        
        
        Flux.bus.performInBusQueue {
            store.startStateTransaction()
            mutation(store)
        }
        
        
        let chain = ChainReaction(flask:self, react:react, abort:abort)
        return chain
    }
    
}
