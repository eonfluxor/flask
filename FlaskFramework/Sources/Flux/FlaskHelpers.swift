//
//  FlaskHelpers.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/3/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public typealias FluxEmptyClosure = ()->Void
public typealias FluxNotificationClosure = (_ notification:FluxNotification)->Void
public typealias FluxMutationClosure = (_ payload: FluxPayloadType?,_ react:()->Void, _ abort:()->Void ) -> Void
public typealias ChangeClosure = (_ change:SubstanceChange)->Void
public typealias ReactionClosure<T> = (_ attachedTo:T, _ reaction: FlaskReaction) -> Void
public typealias MutationClosure<T> = (_ substance:T,_ react:()-> Void,_ abort:()-> Void) -> Void

public typealias FluxPayloadType = [String:Any?]
public typealias FlaskDictType = [String:AnyHashable?]
public typealias SubstanceMixer = String
public typealias StateProp = String


let BUS_LOCKED_BY="BUS_LOCKED_BY"
let FLUX_BUS_NAME="FLUX_BUS_NAME"

public func isNilorNull(_ value:Any?)->Bool{
    if value == nil || ((value as? NSNull) != nil){
        return true
    }
  
    return false
}
func StringFromPointer(_ object:Any)->String{
    return "\(Unmanaged.passUnretained(object as AnyObject).toOpaque())"
}


protocol FlaskAnyWithInit{
    init() //construct at initial state
}

public class FlaskEquatable: Equatable{
    public static func == (lhs: FlaskEquatable, rhs: FlaskEquatable) -> Bool {
        return lhs === rhs
    }
}


public class FlaskWeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}

public enum NoMixers:SubstanceMixer{
    case None
}


