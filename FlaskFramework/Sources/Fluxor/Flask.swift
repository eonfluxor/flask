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
    
    public var reactor:FlaskReactorClosure<D>  = { owner,reaction in }
    
    required public init(_ owner:D){
        self.owner=owner
    }
    
    /// MARK: -
    
    override public func bind(){
        guard (self.owner) != nil else {
            return assertionFailure("a owner is required")
        }
        super.bind()
    }
    
    override func handleMutation(_ reaction:FlaskReaction){
        
        
        if let owner = self.owner {
            reactor(owner,reaction)
        }else{
            //dispose flask when the owner is no longer present
            FlaskReactorManager.removeFlaskReactor(self)
        }
    }
    
    override public func getOwner()->AnyObject?{
        return owner as AnyObject?
    }
    
}


public class FlaskConcrete:FlaskAnyEquatable{
    
    var molecules:[MoleculeConcrete]=[]
    var binded = false
    
    
    func bindMolecule(_ molecule:MoleculeConcrete){
        bindMolecules([molecule])
    }
    
    func bindMolecules(_ bindedMolecules:[MoleculeConcrete]){
        molecules = bindedMolecules
        bind()
    }
    
    public func getOwner()->AnyObject?{
        return nil
    }
    
    public func bind(){
        
        assert(!binded,"Already bounded. It's required  to balance bind/unbind calls")
        assert(!molecules.isEmpty,"At least one molecule is required")
        
        binded = true
        
        for molecule in molecules {
           
            { [weak self] in
                if let wself = self {
                    Lab.Dispatcher.bindFlaskReactor(molecule, flask: wself)
                }
            }()
            
            molecule.bindMixers()
        }
        
        
    }
    
    public func unbind(_ explicit:Bool = true){
        
        if(explicit && !binded){
            assert(binded,"Not bounded. It's required  to balance bind/unbind calls")
        }
        
        if(!binded){return}
        binded = false
        
        for molecule in molecules {
            { [weak self] in
                if let wself = self {
                    Lab.Dispatcher.unbindFlaskReactor(molecule, flask: wself)
                }
            }()
            
            molecule.unbindMixers()
        }
    }
    
    ///
    func handleMutation(_ reaction:FlaskReaction){}
    
    @discardableResult public func mix<T:MoleculeConcrete>(_ aMolecule:T, _ mixer:@escaping FlaskMixParams<T>)->FlaskConcrete{
        
        let molecule = self.molecule(aMolecule)
        molecule.mix(mixer)
        
        return self
    }
    
 
    //////////////////
    // MARK: - PUBLIC METHODS
    
    public func molecule<T:MoleculeConcrete>(_ molecule:T)->T{
        
        let registered = molecules.contains { (aMolecule) -> Bool in
            aMolecule === molecule
        }
        assert(registered,"Molecule instance is not binded to this flask")
        return molecule
    }

}


