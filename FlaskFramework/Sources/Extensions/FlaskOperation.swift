//
//  FlaskOperation.swift
//  Flask-iOS
//
//  Created by hassan uriostegui on 9/20/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX) || os(macOS)
import Cocoa
#endif


open class FlaskOperation: Operation {
    
    public typealias AsyncBlock = (FlaskOperation) -> Void
    
    public var block: AsyncBlock?
    public var fluxLock: FluxLock?
    
    public init(block: @escaping AsyncBlock) {
        super.init()
        self.block = block
    }
    
    override open func start() {
        isExecuting = true
        if let executingBlock = self.block {
            executingBlock(self)
        } else {
            complete()
        }
    }
    
    func complete() {
        isExecuting = false
        isFinished = true
    }
    
    private var _executing: Bool = false
    override open var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override open var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
}

public extension OperationQueue {
    
    public func addOperationWithAsyncBlock(block: FlaskOperation) {
        self.addOperation(block)
    }
}

