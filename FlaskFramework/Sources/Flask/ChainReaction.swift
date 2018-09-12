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

public struct ChainReaction{
    
    let flask:FlaskConcrete
    public let react:()->Void
    public let abort:()->Void
    
    public func mutate<T:StoreConcrete>(_ aStore:T, _ bus:@escaping (_ store:T) -> Void)->ChainReaction{
        
        let store = flask.store(aStore)
        
        store.stateTransaction({
            bus(store)
            return true
        })
        
        let chain = ChainReaction(flask:flask, react:react, abort:abort)
        return chain
    }
    
}

public extension FlaskConcrete{
  
    public func mutate<T:StoreConcrete>(_ aStore:T, _ bus:@escaping(_ store:T) -> Void)->ChainReaction{
        
        let  react = { [weak self] in
            if let stores = self?.stores {
                for store in stores{
                    store.reduceAndReact()
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
            bus(store)
            return true
        })
        
        let chain = ChainReaction(flask:self, react:react, abort:abort)
        return chain
    }
    
}
