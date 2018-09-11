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


typealias FluxStoreMutator = (_ payload: Any?,_ commit:()->Void, _ abort:()->Void ) -> Void
typealias FluxReactionClosure = (_ change:FluxChangeTemplate)->Void
typealias FluxorClosure<T> = (_ ownedBy:T, _ reaction: FluxReaction) -> Void
typealias FluxStateDictionaryType = Dictionary<String,AnyHashable?>
typealias FluxNil = (AnyHashable?)
typealias FluxMutatorParams<T> = (_ store:T,_ commit:()-> Void,_ abort:()-> Void) -> Void
typealias FluxActions = String
typealias FluxProps = String


let FLUX_ACTION_SKIP_LOCKS="FLUX_ACTION_SKIP_LOCKS"
let FLUX_ACTION_NAME="FLUX_ACTION_NAME"

func isFluxNil(_ value:Any?)->Bool{
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


