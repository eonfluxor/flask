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
    
    let flask:FlaskConcrete
    public let commit:()->Void
    public let abort:()->Void
    
    public func mix<T:MoleculeConcrete>(_ aMolecule:T, _ mixer:@escaping (_ molecule:T) -> Void)->FlaskChainReaction{
        
        let molecule = flask.molecule(aMolecule)
        
        molecule.stateTransaction({
            mixer(molecule)
            return true
        })
        
        let chain = FlaskChainReaction(flask:flask, commit:commit, abort:abort)
        return chain
    }
    
}

public extension FlaskConcrete{
    
//    func mix()->FlaskChainReaction{
//        
//        if let molecule = molecules.first {
//            return mix(molecule)
//        }
//        assert(false, "error: there are not molecules binded")
//    }
    
//    func mix<T:MoleculeConcrete>(_ aMolecule:T)->FlaskChainReaction{
//
//        let  commit = { [weak self] in
//            if let molecules = self?.molecules {
//                for molecule in molecules{
//                    molecule.handleMutation()
//                }
//            }
//        }
//
//        let abort = {
//            [weak self] in
//            if let molecules = self?.molecules {
//                for molecule in molecules{
//                    molecule.abortStateTransaction();
//                }
//            }
//        }
//        let chain = FlaskChainReaction(flask:self, commit:commit, abort:abort)
//        return chain
//    }
//
    
    public func mix<T:MoleculeConcrete>(_ aMolecule:T, _ mixer:@escaping(_ molecule:T) -> Void)->FlaskChainReaction{
        
        let  commit = { [weak self] in
            if let molecules = self?.molecules {
                for molecule in molecules{
                    molecule.handleMutation()
                }
            }
        }
        
        let abort = {
            [weak self] in
            if let molecules = self?.molecules {
                for molecule in molecules{
                    molecule.abortStateTransaction();
                }
            }
        }
        
        let molecule = self.molecule(aMolecule)
        
        molecule.stateTransaction({
            mixer(molecule)
            return true
        })
        
        let chain = FlaskChainReaction(flask:self, commit:commit, abort:abort)
        return chain
    }
    
}
