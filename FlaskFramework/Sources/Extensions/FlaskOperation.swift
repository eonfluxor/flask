//
//  FlaskOperation.swift
//  Flask-iOS
//
//  Created by hassan uriostegui on 9/20/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import UIKit


class FlaskOperation: Operation {
    
    typealias AsyncBlock = (FlaskOperation) -> Void
    
    var block: AsyncBlock?
    var fluxLock: FluxLock?
    
    init(block: @escaping AsyncBlock) {
        super.init()
        self.block = block
    }
    
    override func start() {
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
    override var isExecuting: Bool {
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
    override var isFinished: Bool {
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

extension OperationQueue {
    
    func addOperationWithAsyncBlock(block: FlaskOperation) {
        self.addOperation(block)
    }
}

