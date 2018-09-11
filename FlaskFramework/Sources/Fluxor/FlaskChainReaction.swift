//
//  FlaskReactorChain.swift
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

public struct FlaskChainReaction{
    
    let flux:FlaskReactorConcrete
    public let commit:()->Void
    public let abort:()->Void
    
    public func mutate<T:FlaskStoreConcrete>(_ aStore:T, _ mutator:@escaping (_ store:T) -> Void)->FlaskChainReaction{
        
        let store = flux.store(aStore)
        
        store.stateTransaction({
            mutator(store)
            return true
        })
        
        let chain = FlaskChainReaction(flux:flux, commit:commit, abort:abort)
        return chain
    }
    
}

public extension FlaskReactorConcrete{
    
//    func mutate()->FlaskChainReaction{
//        
//        if let store = stores.first {
//            return mutate(store)
//        }
//        assert(false, "error: there are not stores binded")
//    }
    
//    func mutate<T:FlaskStoreConcrete>(_ aStore:T)->FlaskChainReaction{
//
//        let  commit = { [weak self] in
//            if let stores = self?.stores {
//                for store in stores{
//                    store.handleMutation()
//                }
//            }
//        }
//
//        let abort = {
//            [weak self] in
//            if let stores = self?.stores {
//                for store in stores{
//                    store.abortStateTransaction();
//                }
//            }
//        }
//        let chain = FlaskChainReaction(flux:self, commit:commit, abort:abort)
//        return chain
//    }
//
    
    public func mutate<T:FlaskStoreConcrete>(_ aStore:T, _ mutator:@escaping(_ store:T) -> Void)->FlaskChainReaction{
        
        let  commit = { [weak self] in
            if let stores = self?.stores {
                for store in stores{
                    store.handleMutation()
                }
            }
        }
        
        let abort = {
            [weak self] in
            if let stores = self?.stores {
                for store in stores{
                    store.abortStateTransaction();
                }
            }
        }
        
        let store = self.store(aStore)
        
        store.stateTransaction({
            mutator(store)
            return true
        })
        
        let chain = FlaskChainReaction(flux:self, commit:commit, abort:abort)
        return chain
    }
    
}
