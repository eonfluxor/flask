//
//  FluxNotifier.swift
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


public struct FluxNotification{
    let mixer:FluxMixer
    let object:AnyObject?
    let payload:FluxPayload?
//    let react:()->
}

public class FluxObserver:FlaskEquatable{
    let callback:FluxCallback
    let objectRef:FlaskWeakRef<AnyObject>
    
    required public init(callback:@escaping FluxCallback, objectRef:FlaskWeakRef<AnyObject>){
        self.callback = callback
        self.objectRef = objectRef
    }
}

public class FluxNotifier {

    static var observersMap:[FluxMixer:[FluxObserver]]=[:]
}

extension FluxNotifier {
    
    static public func addCallback(forMixer mixer:FluxMixer,
                                   object: AnyObject?,
                                   _ callback:@escaping FluxCallback){
        
        let ref = FlaskWeakRef(value: object)
        let observer = FluxObserver(callback: callback, objectRef:ref)
        addObserver(forMixer: mixer, observer: observer )
    }
    
    static public func removeObservers(forObject object:AnyObject){
        
        var newMap:[FluxMixer:[FluxObserver]]=[:]
        for key in observersMap.keys {
            let observers = observersMap[key]!
            newMap[key] = observers.filter { $0.objectRef.value !== object}
            
        }
        observersMap = newMap
    }
    
    static public func addObserver(forMixer mixer:FluxMixer,
                                   observer:FluxObserver){
        
        var observers = getObservers(forMixer: mixer)
        observers.append(observer)
        
        setObservers(forMixer: mixer, observers: observers)
        
    }
    
   
    
}

extension FluxNotifier{
    
    static public func getObservers(forMixer mixer:FluxMixer)->[FluxObserver]{
        
        if let observers = observersMap[mixer]{
            return observers
        }
        return []
    }
    
    static public func setObservers(forMixer mixer:FluxMixer, observers:[FluxObserver]){
        
        observersMap[mixer] = observers
    }
    
}

extension FluxNotifier{
    
    static public func postNotification(forMixer mixer:FluxMixer, payload:FluxPayload?, completion:FluxCompletionClosure? = nil){
        let observers = getObservers(forMixer: mixer)

        for observer in observers {
            
            let notification = FluxNotification(mixer: mixer,
                                               object:observer.objectRef.value,
                                               payload: payload)
            observer.callback(notification)
        }
        
        if let completion = completion {
            completion()
        }
    }
}

