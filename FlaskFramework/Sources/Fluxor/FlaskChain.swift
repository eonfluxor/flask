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

public struct FlaskMutationChain{
    
    let flux:FlaskReactorConcrete
    public let commit:()->Void
    public let abort:()->Void
    
    public func mutate<T:FlaskStoreConcrete>(_ aStore:T, _ mutator:@escaping (_ store:T) -> Void)->FlaskMutationChain{
        
        let store = flux.store(aStore)
        
        store.stateTransaction({
            mutator(store)
            return true
        })
        
        let chain = FlaskMutationChain(flux:flux, commit:commit, abort:abort)
        return chain
    }
    
}

public extension FlaskReactorConcrete{
    
//    func mutate()->FlaskMutationChain{
//        
//        if let store = stores.first {
//            return mutate(store)
//        }
//        assert(false, "error: there are not stores binded")
//    }
    
//    func mutate<T:FlaskStoreConcrete>(_ aStore:T)->FlaskMutationChain{
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
//        let chain = FlaskMutationChain(flux:self, commit:commit, abort:abort)
//        return chain
//    }
//
    
    public func mutate<T:FlaskStoreConcrete>(_ aStore:T, _ mutator:@escaping(_ store:T) -> Void)->FlaskMutationChain{
        
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
        
        let chain = FlaskMutationChain(flux:self, commit:commit, abort:abort)
        return chain
    }
    
}
