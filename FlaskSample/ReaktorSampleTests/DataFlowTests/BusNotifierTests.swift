//
//  FluxNotifier.swift
//  Flask
//
//  Created by hassan uriostegui on 9/11/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import XCTest
import Flask


class notifierTests: SetupFlaskTests {
    
    func testNotifier(){
        
        let expectation = self.expectation(description: "perform notification")
        let payload = ["foo":"bar"]
        let mixer = "test"
        
        FluxNotifier.addCallback(forMixer: mixer, object: self) { (notification) in
            
            let payload = notification.payload
            XCTAssert((payload!["foo"] as! String) == "bar")
            
            expectation.fulfill()
        }
        
        FluxNotifier.postNotification(forMixer: mixer, payload: payload)
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
//    func testRemoveNotifier(){
        //TODO
//    }
}
