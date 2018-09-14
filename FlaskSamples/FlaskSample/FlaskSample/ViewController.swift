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
    
    //Mark: an inline Substance
    let substance = NewSubstance(definedBy: AppState.self)
    
    func flaskReactor(reaction: FlaskReaction) {
        
        //using the state enums
        reaction
            .at(substance)?
            .on(AppState.prop.counter) { (change) in
                print("local substance counter = \(substance.state.counter)")
        }
        
        
        //using prop as string
        reaction
            .at(Subs.appReactive)?
            .on("counter") { (change) in
                print("global substance counter = \(Subs.appReactive.state.counter)")
        }
        
        
        // if no name conflicts the .at(store) may be skipped
        reaction.on(AppState.prop.title) { (change) in
            print("global title = \(Subs.appReactive.state.title)")
        }
        
        reaction.on(AppState.prop.asyncResult) { (change) in
            print("global title = \(Subs.appReactive.state.asyncResult)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                //release when the operation is completed
                reaction.onLock?.release()
            });
        }
        
      
        
    }
    
    override func viewDidLoad() {
       
        AttachFlaskReactor(to:self, mixing:[substance, Subs.appReactive])
        produceTestReaction()
    }
    
    
    func produceTestReaction(){
        
        //dipose saved state between sessions for testing
        substance.shouldArchive = false
        

        Flask.applyMixer(EnvMixers.Login)
        
        GetFlaskReactor(at:self)
            .toMix(self.substance) { (substance) in
                
                //local substance
                substance.prop.counter = 10
                
            }.with(Subs.appReactive) { (substance) in
                
                //global substance
                substance.prop.counter = 1000
                
            }.andReact()
        
        // a simple lock
        let lock = Flask.lock()
        
        // perform operations while the flux is paused
        // then release
        lock.release()
        
        // a mixer lock, blocks the normal flux
        // an immediately performs this mixer
        Flask.lock(withMixer: EnvMixers.AsyncAction)
        
        // logout won't be performed until the above lock is released (see reactor code)
        Flask.applyMixer(EnvMixers.Logout,payload:["user":userObject])
    
    }
    
}

