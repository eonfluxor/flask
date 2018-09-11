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

extension FlaskStore {
    
    public func archiveKeySpace()->String{
        return "1"
    }
    
    public func archiveKey()->String{
        return "Fx.\(archiveKeySpace()).\(name())"
    }
    
    public func archiveDelay()->Double{
        return 2.0
    }
    
    public func archiveDisabled()->Bool{
        return false
    }
}

extension FlaskStore {
    
    func archiveIntent<T:FlaskState>(_ state:T){
        
        guard !archiveDisabled() else{
            return
        }
        
        let key = archiveKey()
        let delay = archiveDelay()
        Kron.idle( delay , key:key){ [weak self] key,ctx in
            self?.archiveNow(state)
        }
        
    }
    
    func archiveNow<T:FlaskState>(_ state:T){
        
        archiveQueue.addOperation { [weak self] in
            
            DispatchQueue.global().async { [weak self] in
                
                do{
                    guard self != nil else {return}
                    
                    let key = self!.archiveKey()
                    let data = try FlaskSerializer.dataFromState(state)
                    
                    if let data = data {
                        
                        UserDefaults.standard.set(data,forKey:key)
                        UserDefaults.standard.synchronize()
                        
                    }else{
                        fatalError("Serialization error")
                    }
                    
                } catch{
                    fatalError("Serialization error")
                    //TODO: log
                }
            }
        }
        
    }
}
extension FlaskStore {
    
    @discardableResult
    func unarchiveIntent()->Bool{
        
        guard !archiveDisabled() else{
            return false
        }
        
        do {
            
            let key = archiveKey()
            let data = UserDefaults.standard.value(forKey: key)
            
            if ((data as? Data) != nil) {
                state = try FlaskSerializer.stateFromData(data as! Data)
                setCurrentState(state)
            }
            
        } catch {
            fatalError("Deserialization error")
        }
        
        return true
    }
}

extension FlaskStore {
    public func purgeArchive(){
        let key = archiveKey()
        UserDefaults.standard.removeObject(forKey: key)
        
    }
}

