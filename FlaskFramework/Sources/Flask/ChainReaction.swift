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
    
    public func mix<T:SubstanceConcrete>(_ aSubstance:T, _ mixer:@escaping (_ substance:T) -> Void)->ChainReaction{
        
        let substance = flask.substance(aSubstance)
        
        substance.atomsTransaction({
            mixer(substance)
            return true
        })
        
        let chain = ChainReaction(flask:flask, react:react, abort:abort)
        return chain
    }
    
}

public extension FlaskConcrete{
  
    public func mix<T:SubstanceConcrete>(_ aSubstance:T, _ mixer:@escaping(_ substance:T) -> Void)->ChainReaction{
        
        let  react = { [weak self] in
            if let substances = self?.substances {
                for substance in substances{
                    substance.handleMix()
                }
            }
        }
        
        let abort = {
            [weak self] in
            if let substances = self?.substances {
                for substance in substances{
                    substance.abortAtomsTransaction();
                }
            }
        }
        
        let substance = self.substance(aSubstance)
        
        substance.atomsTransaction({
            mixer(substance)
            return true
        })
        
        let chain = ChainReaction(flask:self, react:react, abort:abort)
        return chain
    }
    
}
