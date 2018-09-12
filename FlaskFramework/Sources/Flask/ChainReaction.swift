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

typealias ChainedStoresClosure = (_ chainedStores:[StoreConcrete])->Void

public class ChainReaction{
    
    let flask:FlaskConcrete
    var _react:ChainedStoresClosure
    var _abort:ChainedStoresClosure
    
    init(flask:FlaskConcrete,react:@escaping ChainedStoresClosure,abort:@escaping ChainedStoresClosure) {
        self.flask = flask
        self._react = react
        self._abort = abort
    }
    
    public func abort(){
        andAbort()
    }
    
    public func react(){
        andReact()
    }
    public func andReact(){
        let stores:[StoreConcrete] = []
        _react(stores)
    }
    
    public func andAbort(){
        let stores:[StoreConcrete] = []
        _abort(stores)
    }
    
    public func andMutate<T:StoreConcrete>(_ aStore:T, _ mutation:@escaping(_ store:T) -> Void)->ChainReaction{
        return mutate(aStore, mutation)
    }
    
    public func mutate<T:StoreConcrete>(_ aStore:T, _ mutation:@escaping (_ store:T) -> Void)->ChainReaction{
        
        let store = flask.store(aStore)
        
        let reactInChain = _react
        let abortInChain = _abort
        
        _react = { (chainedStores) in
            
            var chainedStoresMut = chainedStores
            chainedStoresMut.append(store)
            reactInChain(chainedStoresMut)
            
        }
        
        _abort = { (chainedStores) in
            
            var chainedStoresMut = chainedStores
            chainedStoresMut.append(store)
            abortInChain(chainedStoresMut)
            
        }
        
        Flux.bus.performInBusQueue {
            store.startStateTransaction()
            mutation(store)
            store.finishStateTransaction()
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
        
       
       
        let  react:ChainedStoresClosure = {  [weak self] (chainedStores)  in
            
            var chainedStoresMut = chainedStores
            chainedStoresMut.append(store)
            self?.reduceStoresChain(chainedStoresMut)
            
        }
        
        let abort:ChainedStoresClosure = {  [weak self] (chainedStores)   in
           
            var chainedStoresMut = chainedStores
            chainedStoresMut.append(store)
            self?.reduceStoresChain(chainedStoresMut,abort: true)

        }
        
        
        Flux.bus.performInBusQueue {
            store.startStateTransaction()
            mutation(store)
            store.finishStateTransaction()
        }
        
        
        let chain = ChainReaction(flask:self, react:react, abort:abort)
        return chain
    }
    
    func reduceStoresChain(_ chainedStores:[StoreConcrete], abort:Bool = false){
       
        let uniqueStores = Array(Set<StoreConcrete>(chainedStores))
        
        var reduceAction:(_ store:StoreConcrete)->Void = { store in
            store.reduceAndReact()
        }
        
        if abort == true {
            reduceAction = { store in
                store.abortStateTransaction()
            }
        }
        
        for store in uniqueStores{
            Flux.bus.performInBusQueue {
                reduceAction(store)
            }
        }
        
        
    }
    
}
