//
//  FluxRef.swift
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

class FluxRef: NSObject, Codable{
    
    private(set) weak var object:NSObject? 
    
    init(_ object:NSObject){
        self.object = object
    }
    ///// required
    
    static func == (lhs: FluxRef, rhs: FluxRef) -> Bool {
        return lhs.object == rhs.object
    }
    
    required init(from decoder: Decoder) throws {}
    func encode(to encoder: Encoder) throws {}
    
}
