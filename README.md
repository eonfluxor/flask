 <p align="center"> 
    <img src="http://res.cloudinary.com/dmje5xfzh/image/upload/c_scale,r_60,w_280/v1536646955/static/Flask-logo.png" alt="alternate text">
 </p>
 

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Flask.svg)](#cocoapods) 
[![GitHub release](https://img.shields.io/github/release/eonfluxor/Flask.svg)](https://github.com/eonfluxor/delay/releases) 
![Swift 4.0](https://img.shields.io/badge/Swift-4.1-orange.svg) 
![platforms](https://img.shields.io/cocoapods/p/Flask.svg)
[![Build Status](https://travis-ci.org/eonfluxor/flask.svg?branch=master)](https://travis-ci.org/eonfluxor/flask)

**Supported Swift Versions:** Swift 4.0

# What is Flask?
Flask is a multiplatform **[ iOS | OSX | tvOS ]** implementation of the unidirectional data flow architecture in Swift. Flask offers a *friendly API* and a robust feature set. 

While the Flux architeture is abstract, explaining Flask is easy:

> ###Flask lets you `Mix` `Substances` and `React` to their `State` `Changes`

Easy right?

As such to preserve this natural intuition  `Flux Stores` are called `Substances` in  Flask. A `substance` would represents any homogeneous data structure in your application *(ie. feed, settings, or the application itself).*

Flask allows to implement both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) through a unified architecture.

And it's also easy to explain:

> ###You can create `ReactiveSubstances` that `React` to environmental events, or plain `Substances` that are `Mixed` only inside your Flask

Also very inituituve!

And it's a direct analogy between the *Fluxor* pattern of `Reactive Stores` as `Reactive Substances`. And also the *Redux* pattern of `Store Reducers`  as a plain `Substance`.

## Motivation

Flask should deliver the most robust feature set accesible through the most friendly API.

With this in mind Flask goes beyond the nolvety of this architecture to develop an expressive API borrowing semantics from high school lab classes creating a framework that is easy to understand through analogies of the physical world.

All this while the core technology offers a unified implementation of both the `Redux` and `Fluxor` patterns while delivering advanced features not available in other frameworks (such as locks and nested keys reduction). 

## Redux Style

This is a gist of a basic ReSwift-like implementation. 

```swift
struct AppState : State{

	enum prop: StateProp{
	  case counter, text
	}
	
	var counter = 0
	var text = ""
}
```

```swift
class ViewController: UIViewController, FlaskReactor  {
       
    let substance = NewSubstance(definedBy: AppState)
       
    func flaskReactor(reaction: FlaskReaction) {
    
        reaction.on(AppState.prop.counter) { (change) in
           print("counter = \(substance.state.counter)")
        }
        reaction.on(AppState.prop.text) { (change) in
            print("text = \(substance.state.text)")
        }
        
    }
    
    override func viewDidLoad() {
      
        AttachFlaskReactor(to:self, mixing:substance)
        produceTestReaction()
    }
    
 
    func produceTestReaction(){    
    
        GetFlaskReactor(from:self)
            .toMix(self.substance!) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance!) { (substance) in
                substance.prop.text = "changed!"
            }.andReact()
            
    }
    
}

```
While the code is compact there's a lot of magic happening behind the scenes: Some things to note:

* State is a read only property and it'a protected during the `mix` operatons.
* While `mixing` you would mutate the state using `prop` (properties) instead of state.
* Using `AttachFlaskReactor` creates a managed `Flask` instance that is **automatically disposed** when its owner instance (ViewController in this case) turns into `nil`.  
* Optionally you can call `DetachFlaskReactor(from:)` to explicitly dispose your Flask.

Keep in mind that:
 
* It's possible to instantiate Flask using a substances array: `AttachFlaskReactor(to:self, mixing:[app,settings,login])`
* These global functions are just idiomatic suggar and a lower-level API is also available for more granular control.

## Fluxor Style


## Why Flask?

Flask implements both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) through a unified architecture. Aditionally provides unique features not found in similar frameworks:

* Binding multiple stores
* Reduce changes in nested keys
* Locks and exclusive dispatch
* Automatic archive / unarchive
* Chained mutations
* Automatic unsubscription


## Documentation

Self-generated documentation available here:

[Documentation](https://eonfluxor.github.io/flask/)

## CocoaPods

If you use [CocoaPods](https://cocoapods.org/pods/Flask) to manage your dependencies, simply add
Kron to your `Podfile`:

```
pod 'Flask'
```

And then import the module

```
import Flask
```
   
   
## More Examples

```
// Coming soon
```

## Have a question?
If you need any help, please visit our GitHub issues. Feel free to file an issue if you do not manage to find any solution from the archives.

You can also reach us at: 

`eonfluxor@gmail.com `

## About

**Flask** created by [Hassan Uriostegui](http://linkedin.com/in/hassanvfx) 
