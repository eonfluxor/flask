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
    
    var molecules:[MoleculeConcrete]=[]
    var filled = false
    
    
    func defineMolecule(_ molecule:MoleculeConcrete){
        defineMolecules([molecule])
    }
    
    func defineMolecules(_ mixinMolecules:[MoleculeConcrete]){
        molecules = mixinMolecules
        
    }
    
    public func getOwner()->AnyObject?{
        return nil
    }
    
    public func fill(){
        
        assert(!filled,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!molecules.isEmpty,"At least one molecule is required")
        
        filled = true
        
        for molecule in molecules {
           
            { [weak self] in
                if let wself = self {
                    Lab.mixer.fillFlask(molecule, flask: wself)
                }
            }()
            
            molecule.defineMixers()
        }
        
        
    }
    
    public func empty(_ explicit:Bool = true){
        
        if(explicit && !filled){
            assert(filled,"Not binded. It's required  to balance bind/unbind calls")
        }
        
        if(!filled){return}
        filled = false
        
        for molecule in molecules {
            { [weak self] in
                if let wself = self {
                    Lab.mixer.emptyFlask(molecule, flask: wself)
                }
            }()
            
            molecule.undefineMixers()
        }
    }
    
    ///
    func handleReaction(_ reaction:FlaskReaction){}
    
//    @discardableResult public func mix<T:MoleculeConcrete>(_ aMolecule:T, _ mixer:@escaping MixParams<T>)->FlaskConcrete{
//        
//        let molecule = self.molecule(aMolecule)
//        molecule.mix(mixer)
//        
//        return self
//    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func molecule<T:MoleculeConcrete>(_ molecule:T)->T{
        
        let registered = molecules.contains { (aMolecule) -> Bool in
            aMolecule === molecule
        }
        assert(registered,"Molecule instance is not mixin to this flask")
        return molecule
    }

}


