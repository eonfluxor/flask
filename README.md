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

### Flask lets you `Mix` `Substances` and `React` to their `State` `Changes`

To preserve this natural intuition in Flask `Flux Stores` are called `Substances`. Thus a `substance` would represents any homogeneous data structure in your application (ie. Feed, Settings, or the application itself). 

Flask allows to implement both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) through a unified architecture:

### You can create `ReactiveSubstances` that `React` to Global Events, or plain `Substances` that are `Mixed` in your Flask

The above conveys the ability of using the `Fluxor` pattern of `Reactive Stores` (as `Reactive Substances`) and the `Redux` pattern of `Store Reducers`  (as a plain `Substance`).

## Redux Style

This is a gist of a basic ReSwift-like implementation.

```swift


class ViewController: UIViewController, FlaskReactor  {
    
    var substance:ReactiveSubstance? = App()
    
    func flaskReactor( reaction:FlaskReaction) {
        reaction.on(AppState.prop.counter) { (change) in
            expecation?.fulfill()
        }
        reaction.on(AppState.prop.text) { (change) in
            expecation2?.fulfill()
        }
    }
    
    override func setUp() {
        substance!.name(as:"chain tests")
        AttachFlaskReactor(to:self, mixing:[substance!])
        expecation = self.expectation(description: "callback on counter")
        expecation2 = self.expectation(description: "callback on text")
        
    }
    override func tearDown(){
        //it needs to explictely detached because the test keeps owner isntance reference alive after this
        DetachFlaskReactor(from: self)
        substance = nil
    }
    
    func testFlaskAPI(){
        
        UseFlaskReactor(at:self)
            .toMix(self.substance!) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance!) { (substance) in
                substance.prop.text = "text"
            }.andReact()
        
        waitForExpectations(timeout: 2, handler: nil)
      
    }
    
}

```


## Fluxor Style


## Why Flask?

Flask implements both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) through a unified architecture. Aditionally provides unique features not found in similar frameworks:

* Binding multiple stores
* Reduce changes in nested keys
* Locks and exclusive dispatch
* Automatic archive / unarchive
* Chained mutations
* Automatic unsubscription


## Motivation
Flask is designed with the following goals:

* Support Fluxxor and Redux patterns
* Bind single or multiple stores
* Reduce changes in nested keys
* Dispatch locks and exclusive Dispatch
* Automatic State archive / unarchive
* Inline mutations like Redux
* Event mutations like Fluxxor

When a event is dispatched, there is a guarantee that all stores will be mutated and the reaction

The naming semantics in Flask are built around four commonly used Laboratory concepts: Lab, Flask, Substance and State.


1. feature


### Why Flask?

* reason


### Gist

```
//TODO
```


## Documentation

Self-generated documentation using jazzy and hosted in github available here:

[Documentation](https://eonfluxor.github.io/Flask/)

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

* **Example**


```
//TODO
```

## Have a question?
If you need any help, please visit our GitHub issues. Feel free to file an issue if you do not manage to find any solution from the archives.

You can also reach us at: 

`eonfluxor@gmail.com `

## About

**Flask** created by [Hassan Uriostegui](http://linkedin.com/in/hassanvfx) 
