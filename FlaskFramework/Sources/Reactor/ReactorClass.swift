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


public class Reactor<O:AnyObject>:ReactorConcrete {
    
    weak var owner:O?
    
    public var handler:ReactionClosure<O>  = { owner,reaction in }
    
    required public init(_ owner:O){
        self.owner=owner
    }
    
    /// MARK: -
    
    override public func bind(){
        guard (self.owner) != nil else {
            return assertionFailure("attaching to an owner is required")
        }
        super.bind()
    }
    
    override public func unbind(explicit:Bool = true){
        super.unbind(explicit:explicit)
    }
    
    override func handleReaction(_ reaction:FlaskReaction){
        
        if let owner = self.owner {
            handler(owner,reaction)
        }else{
            //dispose reactor when the owner is no longer present
            ReactorManager.removeReactor(self)
        }
    }
    
    override public func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class ReactorConcrete:FlaskEquatable{
    
    var substances:[SubstanceConcrete]=[]
    var binded = false
    
    
    func defineSubstance(_ substance:SubstanceConcrete){
        defineSubstances([substance])
    }
    
    func defineSubstances(_ mixingSubstances:[SubstanceConcrete]){
        substances = mixingSubstances
        
    }
    
    public func getOwner()->AnyObject?{
        return nil
    }
    
    public func bind(){
        
        assert(!binded,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!substances.isEmpty,"At least one substance is required")
        
        binded = true
        
        for substance in substances {
           
            { [weak self] in
                if let wself = self {
                    Flask.bus.bindFlask(substance, reactor: wself)
                }
            }()
            
            substance.defineMixers()
        }
        
        
    }
    
    public func unbind(explicit:Bool = true){
        
        if(explicit && !binded){
            assert(binded,"Not binded. It's required  to balance bind/unbind calls")
        }
        
        if(!binded){return}
        binded = false
        
        for substance in substances {
            { [weak self] in
                if let wself = self {
                    Flask.bus.unbindFlask(substance, reactor: wself)
                }
            }()
            
            substance.undefineMixers()
        }
    }
    
    ///
    func handleReaction(_ reaction:FlaskReaction){}
    
//    @discardableResult public mixing<T:SubstanceConcrete>(_ aSubstance:T, _ bus:@escaping MutationClosure<T>)->ReactorConcrete{
//        
//        let substance = self.substance(aSubstance)
//        substance.mixing(bus)
//        
//        return self
//    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func substance<T:SubstanceConcrete>(_ substance:T)->T{
        
        let registered = substances.contains { (aSubstance) -> Bool in
            aSubstance === substance
        }
        assert(registered,"Substance instance is not mixing to this reactor")
        return substance
    }

}


