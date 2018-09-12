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


public typealias BusPayload = [String:Any?]
public typealias BusMutation = (_ payload: Any?,_ react:()->Void, _ abort:()->Void ) -> Void
public typealias ChangeClosure = (_ change:StoreChange)->Void
public typealias ReactionClosure<T> = (_ attachedTo:T, _ reaction: FlaskReaction) -> Void
public typealias FluxDictType = Dictionary<String,AnyHashable?>
public typealias FluxNil = (AnyHashable?)
public typealias MutationParams<T> = (_ store:T,_ react:()-> Void,_ abort:()-> Void) -> Void
public typealias BusEvent = String
public typealias StateName = String


let BUS_LOCKED_BY="BUS_LOCKED_BY"
let FLUX_BUS_NAME="FLUX_BUS_NAME"

public func isNilFlux(_ value:Any?)->Bool{
    if value == nil || ((value as? NSNull) != nil){
        return true
    }
  
    return false
}



protocol FluxAnyWithInit{
    init() //construct at initial state
}

public class FluxEquatable: Equatable{
    public static func == (lhs: FluxEquatable, rhs: FluxEquatable) -> Bool {
        return lhs === rhs
    }
}


public class FluxWeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}


