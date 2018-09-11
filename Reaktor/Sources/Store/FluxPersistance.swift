//
//  FluxPersistance.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

import Delayed

extension FluxStore {
    
    public func persistanceKeySpace()->String{
        return "1"
    }
    
    public func persistanceKey()->String{
        return "Fx.\(persistanceKeySpace()).\(name())"
    }
    
    public func persistanceDelay()->Double{
        return 2.0
    }
    
    public func persistanceDisabled()->Bool{
        return false
    }
    
    func persistIntent<T:FluxState>(_ state:T){
        
        guard !persistanceDisabled() else{
            return
        }
        
        let key = persistanceKey()
        let delay = persistanceDelay()
        Kron.idle( delay , key:key){ [weak self] key,ctx in
            self?.persistNow(state)
        }
       
    }
    
    func persistNow<T:FluxState>(_ state:T){
        
        persistanceQueue.addOperation { [weak self] in
            
            do{
                guard self != nil else {return}
                
                let json = try FluxSerializer.jsonFromState(state)
                let key = self!.persistanceKey()
                let data = json.data(using: .utf16)
                
                DispatchQueue.global().async {
                    UserDefaults.standard.set(data,forKey:key)
                    UserDefaults.standard.synchronize()
                }
                
            } catch{
                assert(false,"Serialization error")
                //TODO: log
            }
        }
        
    }
    
  
}

