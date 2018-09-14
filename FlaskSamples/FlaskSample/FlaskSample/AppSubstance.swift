//
//  AppSubstance.swift
//  FlaskSample
//
//  Created by hassan uriostegui on 9/13/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import UIKit
import Flask

//Mark: - A sample State definition

struct AppState : State {
    
    enum prop : StateProp{
        case counter, title, asyncResult
    }
    
    var counter = 0
    var title = ""
    var asyncResult = ""
    var object:FlaskNSRef?
    var map:FlaskDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

//Mark: - A sample Reactive Substance

class AppReactiveSubstance : ReactiveSubstance<AppState,EnvMixers> {
    
    override func defineMixers(){
        
        define(mix: .Login) { (payload, react, abort)  in
            self.prop.title = "signed"
            react()
        }
        
        define(mix: .Logout) { (payload, react, abort)  in
           self.prop.title = "not signedd"
            react()
        }
        
        define(mix: .AsyncAction){ (payload, react, abort)  in
            self.prop.asyncResult = "async action pending"
            react()
        }
        
        define(mix: NavMixers.Home) { (payload, react, abort)  in
        
            abort()
        }
        
        define(mix: NavMixers.Settings) { (payload, react, abort)  in
            //TODO
            abort()
        }
    }
    
}

//Mark: - A sample Substance

class AppSubstance : Substance<AppState> {}

