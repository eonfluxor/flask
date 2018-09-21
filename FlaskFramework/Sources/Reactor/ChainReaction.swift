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

typealias ChainedSubstancesClosure = (_ chainedSubstances:[SubstanceConcrete])->Void

let CHAIN_REACTION_CONTEXT = "ChainReaction"
public class ChainReaction{
    
    let reactor:ReactorConcrete
    var _react:ChainedSubstancesClosure
    var _abort:ChainedSubstancesClosure
    
    init(reactor:ReactorConcrete,react:@escaping ChainedSubstancesClosure,abort:@escaping ChainedSubstancesClosure) {
        self.reactor = reactor
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
        let substances:[SubstanceConcrete] = []
        _react(substances)
    }
    
    public func andAbort(){
        let substances:[SubstanceConcrete] = []
        _abort(substances)
    }
    
    public func with<T:SubstanceConcrete>(_ aSubstance:T, _ mixing:@escaping(_ substance:T) -> Void)->ChainReaction{
        return mix(aSubstance, mixing)
    }
    
    public func and<T:SubstanceConcrete>(_ aSubstance:T, _ mixing:@escaping(_ substance:T) -> Void)->ChainReaction{
        return mix(aSubstance, mixing)
    }
    
    public func mix<T:SubstanceConcrete>(_ aSubstance:T, _ mixing:@escaping (_ substance:T) -> Void)->ChainReaction{
        
        let substance = reactor.substance(aSubstance)
        
        let reactInChain = _react
        let abortInChain = _abort
        
        _react = { (chainedSubstances) in
            
            var chainedSubstancesMut = chainedSubstances
            chainedSubstancesMut.append(substance)
            reactInChain(chainedSubstancesMut)
            
        }
        
        _abort = { (chainedSubstances) in
            
            var chainedSubstancesMut = chainedSubstances
            chainedSubstancesMut.append(substance)
            abortInChain(chainedSubstancesMut)
            
        }
        
        Flask.bus.performInFluxQueue {
            substance.beginStateTransaction(context:CHAIN_REACTION_CONTEXT){
                mixing(substance)
            }
            
        }
        
        let chain = ChainReaction(reactor:reactor, react:_react, abort:_abort)
        return chain
    }
    
}

public extension ReactorConcrete{
    
    public func mixing<T:SubstanceConcrete>(_ aSubstance:T, _ mixing:@escaping(_ substance:T) -> Void)->ChainReaction{
        return mix(aSubstance, mixing)
    }
    
    public func mix<T:SubstanceConcrete>(_ aSubstance:T, _ mixing:@escaping(_ substance:T) -> Void)->ChainReaction{
        
        let substance = self.substance(aSubstance)
        
       
       
        let  react:ChainedSubstancesClosure = {  [weak self] (chainedSubstances)  in
            
            var chainedSubstancesMut = chainedSubstances
            chainedSubstancesMut.append(substance)
            self?.reduceSubstancesChain(chainedSubstancesMut)
            
        }
        
        let abort:ChainedSubstancesClosure = {  [weak self] (chainedSubstances)   in
           
            var chainedSubstancesMut = chainedSubstances
            chainedSubstancesMut.append(substance)
            self?.reduceSubstancesChain(chainedSubstancesMut,abort: true)

        }
        
        
        Flask.bus.performInFluxQueue {
            substance.beginStateTransaction(context:CHAIN_REACTION_CONTEXT){
                mixing(substance)
            }
        }
        
        
        let chain = ChainReaction(reactor:self, react:react, abort:abort)
        return chain
    }
    
    func reduceSubstancesChain(_ chainedSubstances:[SubstanceConcrete], abort:Bool = false){
       
        let uniqueSubstances = Array(Set<SubstanceConcrete>(chainedSubstances))
        
        var reduceAction:(_ substance:SubstanceConcrete)->Void = { substance in
            
            substance.commitStateTransaction(context: CHAIN_REACTION_CONTEXT)
            substance.reduceAndReact()
        }
        
        if abort == true {
            reduceAction = { substance in
                substance.abortStateTransaction(context: CHAIN_REACTION_CONTEXT)
            }
        }
        
        for substance in uniqueSubstances{
            Flask.bus.performInFluxQueue {
                reduceAction(substance)
            }
        }
        
        
    }
    
}
