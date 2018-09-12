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
    let event:BusEvent
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

    static var observersMap:[BusEvent:[BusObserver]]=[:]
}

extension BusNotifier {
    
    static public func addCallback(forEvent event:BusEvent,
                                   object: AnyObject?,
                                   _ callback:@escaping BusCallback){
        
        let ref = FluxWeakRef(value: object)
        let observer = BusObserver(callback: callback, objectRef:ref)
        addObserver(forEvent: event, observer: observer )
    }
    
    static public func removeObservers(forObject object:AnyObject){
        
        var newMap:[BusEvent:[BusObserver]]=[:]
        for key in observersMap.keys {
            let observers = observersMap[key]!
            newMap[key] = observers.filter { $0.objectRef.value !== object}
            
        }
        observersMap = newMap
    }
    
    static public func addObserver(forEvent event:BusEvent,
                                   observer:BusObserver){
        
        var observers = getObservers(forEvent: event)
        observers.append(observer)
        
        setObservers(forEvent: event, observers: observers)
        
    }
    
   
    
}

extension BusNotifier{
    
    static public func getObservers(forEvent event:BusEvent)->[BusObserver]{
        
        if let observers = observersMap[event]{
            return observers
        }
        return []
    }
    
    static public func setObservers(forEvent event:BusEvent, observers:[BusObserver]){
        
        observersMap[event] = observers
    }
    
}

extension BusNotifier{
    
    static public func postNotification(forEvent event:BusEvent, payload:BusPayload?, completion:BusCompletionClosure? = nil){
        let observers = getObservers(forEvent: event)

        for observer in observers {
            
            let notification = BusNotification(event: event,
                                               object:observer.objectRef.value,
                                               payload: payload)
            observer.callback(notification)
        }
        
        if let completion = completion {
            completion()
        }
    }
}
//    NotificationCenter.default.post(
//    name: NSNotification.Name(bus),
//    object: payload,
//    userInfo: .none)
    
    
//    NotificationCenter.default.addObserver(
//    forName: NSNotification.Name(bus),
//    object: nil, queue: OperationQueue.main) { (notification) in

