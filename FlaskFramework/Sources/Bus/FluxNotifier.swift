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
    public let mixer:SubstanceMixer
    public let object:AnyObject?
    public let payload:FluxPayloadType?
//    let react:()->
}

public class FluxObserver:FlaskEquatable{
    let callback:FluxNotificationClosure
    let objectRef:FlaskWeakRef<AnyObject>
    
    required public init(callback:@escaping FluxNotificationClosure, objectRef:FlaskWeakRef<AnyObject>){
        self.callback = callback
        self.objectRef = objectRef
    }
}

public class FluxNotifier {

    static var observersMap:[SubstanceMixer:[FluxObserver]]=[:]
}

extension FluxNotifier {
    
    static public func addCallback(forMixer mixer:SubstanceMixer,
                                   object: AnyObject?,
                                   _ callback:@escaping FluxNotificationClosure){
        
        let ref = FlaskWeakRef(value: object)
        let observer = FluxObserver(callback: callback, objectRef:ref)
        addObserver(forMixer: mixer, observer: observer )
    }
    
    static public func removeObservers(forObject object:AnyObject){
        
        var newMap:[SubstanceMixer:[FluxObserver]]=[:]
        for key in observersMap.keys {
            let observers = observersMap[key]!
            newMap[key] = observers.filter { $0.objectRef.value !== object}
            
        }
        observersMap = newMap
    }
    
    static public func addObserver(forMixer mixer:SubstanceMixer,
                                   observer:FluxObserver){
        
        var observers = getObservers(forMixer: mixer)
        observers.append(observer)
        
        setObservers(forMixer: mixer, observers: observers)
        
    }
    
   
    
}

extension FluxNotifier{
    
    static public func getObservers(forMixer mixer:SubstanceMixer)->[FluxObserver]{
        
        if let observers = observersMap[mixer]{
            return observers
        }
        return []
    }
    
    static public func setObservers(forMixer mixer:SubstanceMixer, observers:[FluxObserver]){
        
        observersMap[mixer] = observers
    }
    
}

extension FluxNotifier{
    
    static public func postNotification(forMixer mixer:SubstanceMixer, payload:FluxPayloadType?, completion:FluxEmptyClosure? = nil){
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

