//
//  ViewController.swift
//  ReaktorSample
//
//  Created by hassan uriostegui on 9/10/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import UIKit
import Flask

struct AppState : State{
    
    enum prop: StateProp{
        case counter, text
    }
    
    var counter = 0
    var text = ""
}

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
        
        GetFlaskReactor(at:self)
            .toMix(self.substance) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance) { (substance) in
                substance.prop.text = "changed!"
            }.andReact()
        
    }

}

