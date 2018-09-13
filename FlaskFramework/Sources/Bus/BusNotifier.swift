//
//  BusNotifier.swift
//  Flask-iOS
//
//  Created by hassan uriostegui on 9/11/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public typealias BusCompletionClosure = ()->Void
public typealias BusBusPayload = [String:Any?]
public typealias BusCallback = (_ notification:BusNotification)->Void

public struct BusNotification{
    let mixer:BusMixer
    let object:AnyObject?
    let payload:BusBusPayload?
//    let react:()->
}

public class BusObserver:FluxEquatable{
    let callback:BusCallback
    let objectRef:FluxWeakRef<AnyObject>
    
    required public init(callback:@escaping BusCallback, objectRef:FluxWeakRef<AnyObject>){
        self.callback = callback
        self.objectRef = objectRef
    }
}

public class BusNotifier {

    static var observersMap:[BusMixer:[BusObserver]]=[:]
}

extension BusNotifier {
    
    static public func addCallback(forMixer mixer:BusMixer,
                                   object: AnyObject?,
                                   _ callback:@escaping BusCallback){
        
        let ref = FluxWeakRef(value: object)
        let observer = BusObserver(callback: callback, objectRef:ref)
        addObserver(forMixer: mixer, observer: observer )
    }
    
    static public func removeObservers(forObject object:AnyObject){
        
        var newMap:[BusMixer:[BusObserver]]=[:]
        for key in observersMap.keys {
            let observers = observersMap[key]!
            newMap[key] = observers.filter { $0.objectRef.value !== object}
            
        }
        observersMap = newMap
    }
    
    static public func addObserver(forMixer mixer:BusMixer,
                                   observer:BusObserver){
        
        var observers = getObservers(forMixer: mixer)
        observers.append(observer)
        
        setObservers(forMixer: mixer, observers: observers)
        
    }
    
   
    
}

extension BusNotifier{
    
    static public func getObservers(forMixer mixer:BusMixer)->[BusObserver]{
        
        if let observers = observersMap[mixer]{
            return observers
        }
        return []
    }
    
    static public func setObservers(forMixer mixer:BusMixer, observers:[BusObserver]){
        
        observersMap[mixer] = observers
    }
    
}

extension BusNotifier{
    
    static public func postNotification(forMixer mixer:BusMixer, payload:BusPayload?, completion:BusCompletionClosure? = nil){
        let observers = getObservers(forMixer: mixer)

        for observer in observers {
            
            let notification = BusNotification(mixer: mixer,
                                               object:observer.objectRef.value,
                                               payload: payload)
            observer.callback(notification)
        }
        
        if let completion = completion {
            completion()
        }
    }
}

