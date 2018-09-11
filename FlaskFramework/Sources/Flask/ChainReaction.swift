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
    
    public func mix<T:MoleculeConcrete>(_ aMolecule:T, _ mixer:@escaping (_ molecule:T) -> Void)->ChainReaction{
        
        let molecule = flask.molecule(aMolecule)
        
        molecule.atomsTransaction({
            mixer(molecule)
            return true
        })
        
        let chain = ChainReaction(flask:flask, react:react, abort:abort)
        return chain
    }
    
}

public extension FlaskConcrete{
    
//    func mix()->ChainReaction{
//        
//        if let molecule = molecules.first {
//            return mix(molecule)
//        }
//        assert(false, "error: there are not molecules mixin")
//    }
    
//    func mix<T:MoleculeConcrete>(_ aMolecule:T)->ChainReaction{
//
//        let  react = { [weak self] in
//            if let molecules = self?.molecules {
//                for molecule in molecules{
//                    molecule.handleMix()
//                }
//            }
//        }
//
//        let abort = {
//            [weak self] in
//            if let molecules = self?.molecules {
//                for molecule in molecules{
//                    molecule.abortAtomTransaction();
//                }
//            }
//        }
//        let chain = ChainReaction(flask:self, react:react, abort:abort)
//        return chain
//    }
//
    
    public func mix<T:MoleculeConcrete>(_ aMolecule:T, _ mixer:@escaping(_ molecule:T) -> Void)->ChainReaction{
        
        let  react = { [weak self] in
            if let molecules = self?.molecules {
                for molecule in molecules{
                    molecule.handleMix()
                }
            }
        }
        
        let abort = {
            [weak self] in
            if let molecules = self?.molecules {
                for molecule in molecules{
                    molecule.abortAtomTransaction();
                }
            }
        }
        
        let molecule = self.molecule(aMolecule)
        
        molecule.atomsTransaction({
            mixer(molecule)
            return true
        })
        
        let chain = ChainReaction(flask:self, react:react, abort:abort)
        return chain
    }
    
}
