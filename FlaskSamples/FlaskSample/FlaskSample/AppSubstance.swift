//
//  AppSubstance.swift
//  FlaskSample
//
//  Created by hassan uriostegui on 9/13/18.
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
