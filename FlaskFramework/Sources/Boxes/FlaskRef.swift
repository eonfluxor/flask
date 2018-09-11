//
//  FlaskRef.swift
//  SwiftyFLUX
//
//  Created by hassan uriostegui on 9/4/18.
//  Copyright © 2018 hassanvfx. All rights reserved.
//


#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif

public class FlaskRef: NSObject, Codable{
    
    private(set) weak var object:NSObject? 
    
    public init(_ object:NSObject){
        self.object = object
    }
    ///// required
    
    static public func == (lhs: FlaskRef, rhs: FlaskRef) -> Bool {
        return lhs.object == rhs.object
    }
    
    required public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {}
    
}
