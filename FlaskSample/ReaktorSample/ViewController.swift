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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

