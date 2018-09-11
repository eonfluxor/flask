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


public typealias SubstanceMixer = (_ payload: Any?,_ react:()->Void, _ abort:()->Void ) -> Void
public typealias ChangeClosure = (_ change:SubstanceChange)->Void
public typealias ReactionClosure<T> = (_ ownedBy:T, _ reaction: FlaskReaction) -> Void
public typealias LabDictType = Dictionary<String,AnyHashable?>
public typealias LabNil = (AnyHashable?)
public typealias MixParams<T> = (_ substance:T,_ react:()-> Void,_ abort:()-> Void) -> Void
public typealias MixerName = String
public typealias StateName = String


let MIXER_PAUSED_BY="MIXER_PAUSED_BY"
let FLUX_MIXER_NAME="FLUX_MIXER_NAME"

public func isLabNil(_ value:Any?)->Bool{
    if value == nil || ((value as? NSNull) != nil){
        return true
    }
  
    return false
}



protocol LabAnyWithInit{
    init() //construct at initial states
}

public class LabEquatable: Equatable{
    public static func == (lhs: LabEquatable, rhs: LabEquatable) -> Bool {
        return lhs === rhs
    }
}


class LabWeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}


