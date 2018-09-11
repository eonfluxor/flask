//
//  FluxHelpers.swift
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


public typealias FluxStoreMutator = (_ payload: Any?,_ commit:()->Void, _ abort:()->Void ) -> Void
public typealias FluxReactionClosure = (_ change:FluxChangeTemplate)->Void
public typealias FluxorClosure<T> = (_ ownedBy:T, _ reaction: FluxReaction) -> Void
public typealias FluxStateDictionaryType = Dictionary<String,AnyHashable?>
public typealias FluxNil = (AnyHashable?)
public typealias FluxMutatorParams<T> = (_ store:T,_ commit:()-> Void,_ abort:()-> Void) -> Void
public typealias FluxActions = String
public typealias FluxProps = String


let FLUX_ACTION_SKIP_LOCKS="FLUX_ACTION_SKIP_LOCKS"
let FLUX_ACTION_NAME="FLUX_ACTION_NAME"

public func isFluxNil(_ value:Any?)->Bool{
    if value == nil || ((value as? NSNull) != nil){
        return true
    }
  
//    Kron.de
    return false
}

func FluxAddress(_ o: UnsafeRawPointer) -> Int {
    return Int(bitPattern: o)
}

func FluxAddressHeap<T: AnyObject>(_ o: T) -> Int {
    return unsafeBitCast(o, to: Int.self)
}


protocol FluxAnyWithInit{
    init() //construct at initial state
}

public class FluxAnyEquatable: Equatable{
    public static func == (lhs: FluxAnyEquatable, rhs: FluxAnyEquatable) -> Bool {
        return lhs === rhs
    }
}


class FluxWeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}


