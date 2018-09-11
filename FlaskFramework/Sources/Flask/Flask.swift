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


public class Flask<D:AnyObject>:FlaskConcrete {
    
    weak var owner:D?
    
    public var reactor:ReactionClosure<D>  = { owner,reaction in }
    
    required public init(_ owner:D){
        self.owner=owner
    }
    
    /// MARK: -
    
    override public func fill(){
        guard (self.owner) != nil else {
            return assertionFailure("a owner is required")
        }
        super.fill()
    }
    
    override public func empty(_ explicit:Bool = true){
        super.empty(explicit)
    }
    
    override func handleReaction(_ reaction:FlaskReaction){
        
        
        if let owner = self.owner {
            reactor(owner,reaction)
        }else{
            //dispose flask when the owner is no longer present
            LabFlaskManager.removeFlask(self)
        }
    }
    
    override public func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class FlaskConcrete:LabAnyEquatable{
    
    var substances:[SubstanceConcrete]=[]
    var filled = false
    
    
    func defineSubstance(_ substance:SubstanceConcrete){
        defineSubstances([substance])
    }
    
    func defineSubstances(_ mixinSubstances:[SubstanceConcrete]){
        substances = mixinSubstances
        
    }
    
    public func getOwner()->AnyObject?{
        return nil
    }
    
    public func fill(){
        
        assert(!filled,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!substances.isEmpty,"At least one substance is required")
        
        filled = true
        
        for substance in substances {
           
            { [weak self] in
                if let wself = self {
                    Lab.mixer.fillFlask(substance, flask: wself)
                }
            }()
            
            substance.defineMixers()
        }
        
        
    }
    
    public func empty(_ explicit:Bool = true){
        
        if(explicit && !filled){
            assert(filled,"Not binded. It's required  to balance bind/unbind calls")
        }
        
        if(!filled){return}
        filled = false
        
        for substance in substances {
            { [weak self] in
                if let wself = self {
                    Lab.mixer.emptyFlask(substance, flask: wself)
                }
            }()
            
            substance.undefineMixers()
        }
    }
    
    ///
    func handleReaction(_ reaction:FlaskReaction){}
    
//    @discardableResult public func mix<T:SubstanceConcrete>(_ aSubstance:T, _ mixer:@escaping MixParams<T>)->FlaskConcrete{
//        
//        let substance = self.substance(aSubstance)
//        substance.mix(mixer)
//        
//        return self
//    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func substance<T:SubstanceConcrete>(_ substance:T)->T{
        
        let registered = substances.contains { (aSubstance) -> Bool in
            aSubstance === substance
        }
        assert(registered,"Substance instance is not mixin to this flask")
        return substance
    }

}


