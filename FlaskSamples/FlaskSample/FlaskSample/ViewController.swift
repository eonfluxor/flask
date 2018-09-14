//
//  ViewController.swift
//  FlaskSample
//
//  Created by hassan uriostegui on 9/13/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import UIKit
import Flask

class ViewController: UIViewController, FlaskReactor  {
    
    let substance = NewSubstance(definedBy: AppState.self)
    
    func flaskReactor(reaction: FlaskReaction) {
        
        reaction.on(AppState.prop.counter) { (change) in
            print("counter = \(substance.state.counter)")
        }
        reaction.on(AppState.prop.text) { (change) in
            print("text = \(substance.state.text)")
        }   
        
    }
    
    override func viewDidLoad() {
       
        AttachFlaskReactor(to:self, mixing:[substance])
        produceTestReaction()
    }
    
    
    func produceTestReaction(){
        
        //dipose saved state between sessions for testing
        substance.shouldArchive = false
        
        GetFlaskReactor(at:self)
            .toMix(self.substance) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance) { (substance) in
                substance.prop.text = "changed!"
            }.andReact()
        
    }
    
}

