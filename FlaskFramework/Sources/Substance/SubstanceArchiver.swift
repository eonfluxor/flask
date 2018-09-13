//
//  FlaskArchiver.swift
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

extension Substance {
    
    public func archiveKeySpace()->String{
        return "1"
    }
    
    public func archiveKey()->String{
        return "Fx.\(archiveKeySpace()).\(name())"
    }
    
    open func archiveDelay()->Double{
        return 2.0
    }
    
    open func archiveDisabled()->Bool{
        return false
    }
}

extension Substance {
    
    func archiveIntent(){
        
        guard !archiveDisabled() else{
            return
        }
        
        let key = archiveKey()
        let delay = archiveDelay()
        Kron.idle(timeOut: delay , key:key){ [weak self] key,ctx in
            if let state = self?.state {
                self?.archiveNow(state)
            }
        }
        
    }
    
    func archiveNow<T:State>(_ state:T){
        
//        archiveQueue.addOperation { [weak self] in
        
            DispatchQueue.global().async { [weak self] in
                
                do{
                    guard self != nil else {return}
                    
                    let key = self!.archiveKey()
                    let data = try SubstanceSerializer.dataFromState(state)
                    
                    if let data = data {
                        
                        UserDefaults.standard.set(data,forKey:key)
                        UserDefaults.standard.synchronize()
                        
                    }else{
                        fatalError("Serialization error")
                    }
                    
                } catch{
                    fatalError("Serialization error")
                }
            }
        
    }
}
extension Substance {
    
    @discardableResult
    func unarchiveIntent()->Bool{
        
        guard !archiveDisabled() else{
            return false
        }
        
        do {
            
            let key = archiveKey()
            let data = UserDefaults.standard.value(forKey: key)
            
            if ((data as? Data) != nil) {
                state = try SubstanceSerializer.stateFromData(data as! Data)
            }
            
        } catch {
            fatalError("Deserialization error")
        }
        
        return true
    }
}

extension Substance {
    public func purgeArchive(){
        let key = archiveKey()
        UserDefaults.standard.removeObject(forKey: key)
        
    }
}

