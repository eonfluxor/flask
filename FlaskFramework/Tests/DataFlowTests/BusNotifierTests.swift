//
//  BusNotifier.swift
//  Flask
//
//  Created by hassan uriostegui on 9/11/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import XCTest


class notifierTests: SetupFlaskTests {
    
    func testNotifier(){
        
        let expectation = self.expectation(description: "perform notification")
        let payload = ["foo":"bar"]
        let event = "test"
        
        BusNotifier.addCallback(forEvent: event, object: self) { (notification) in
            
            let payload = notification.payload
            XCTAssert((payload!["foo"] as! String) == "bar")
            
            expectation.fulfill()
        }
        
        BusNotifier.postNotification(forEvent: event, payload: payload)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
