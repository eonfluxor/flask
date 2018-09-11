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


public typealias MoleculeMutator = (_ payload: Any?,_ commit:()->Void, _ abort:()->Void ) -> Void
public typealias FlaskReactionClosure = (_ change:FlaskChangeTemplate)->Void
public typealias FlaskReactorClosure<T> = (_ ownedBy:T, _ reaction: FlaskReaction) -> Void
public typealias FlaskStateDictionaryType = Dictionary<String,AnyHashable?>
public typealias FlaskNil = (AnyHashable?)
public typealias FlaskMutatorParams<T> = (_ store:T,_ commit:()-> Void,_ abort:()-> Void) -> Void
public typealias FlaskActions = String
public typealias FlaskProps = String


let FLUX_ACTION_SKIP_LOCKS="FLUX_ACTION_SKIP_LOCKS"
let FLUX_ACTION_NAME="FLUX_ACTION_NAME"

public func isFlaskNil(_ value:Any?)->Bool{
    if value == nil || ((value as? NSNull) != nil){
        return true
    }
  
//    Kron.de
    return false
}

func FlaskAddress(_ o: UnsafeRawPointer) -> Int {
    return Int(bitPattern: o)
}

func FlaskAddressHeap<T: AnyObject>(_ o: T) -> Int {
    return unsafeBitCast(o, to: Int.self)
}


protocol FlaskAnyWithInit{
    init() //construct at initial state
}

public class FlaskAnyEquatable: Equatable{
    public static func == (lhs: FlaskAnyEquatable, rhs: FlaskAnyEquatable) -> Bool {
        return lhs === rhs
    }
}


class FlaskWeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}


