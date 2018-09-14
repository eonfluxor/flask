 <p align="center"> 
    <img src="http://res.cloudinary.com/dmje5xfzh/image/upload/c_scale,r_60,w_280/v1536646955/static/Flask-logo.png" alt="alternate text">
 </p>
 

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Flask.svg)](#cocoapods) 
[![GitHub release](https://img.shields.io/github/release/eonfluxor/flask.svg)](https://github.com/eonfluxor/flask/releases) 
![Swift 4.0](https://img.shields.io/badge/Swift-4.1-orange.svg) 
![platforms](https://img.shields.io/cocoapods/p/Flask.svg)
[![Build Status](https://travis-ci.org/eonfluxor/flask.svg?branch=master)](https://travis-ci.org/eonfluxor/flask)

**Supported Swift Versions:** Swift 4.0

# What is Flask?
Flask is a multiplatform **[ iOS | OSX | tvOS ]** implementation of the unidirectional data flow architecture in Swift. Flask offers a *friendly API* and a robust feature set. 

While the Flux architeture is abstract, explaining Flask is easy:

----

> **Flask** lets you **Mix** **Substances** and **React** to their **State** **Changes**

---

Easy right?

As such to preserve this natural intuition  `Flux Stores` are called a `Substance` in  `Flask`. A `Substance` would represents any homogeneous data structure in your application *(ie. feed, settings, or the application itself).*

Flask allows to implement both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) through a unified architecture.

And it's also easy to explain:

----

> ####You can create `ReactiveSubstances` that `React` to environmental events, or plain `Substances` that are `Mixed` only inside your Flask

----
Also very inituituve!

And it's a direct analogy between the *Fluxor* pattern of `Reactive Stores` as a `ReactiveSubstance` . And also the *Redux* pattern of `Store Reducers`  as a plain `Substance`.

## Motivation

Flask should deliver the most robust feature set accesible through the most friendly API.

With this in mind Flask goes beyond the nolvety of this architecture to develop an expressive API borrowing semantics from high school lab classes creating a framework that is easy to understand through analogies of the physical world.

All this while the core technology offers a unified implementation of both the `Redux` and `Fluxor` patterns while delivering advanced features not available in other frameworks (such as locks and nested keys reduction). 

## Redux Style Sample

This is a gist of a basic ReSwift-like implementation. 

>Define Substance Initial `State`

```swift
struct AppState : State{
    
    enum prop: StateProp{
        case counter, text
    }
    
    var counter = 0
    var text = ""
}
```

> Adopt `FlaskReactor` protocol

```swift
class ViewController: UIViewController, FlaskReactor  {
```

> Define a `Substance` instance

  
```swift  
    let substance = NewSubstance(definedBy: AppState.self)
```

> Implement a `FlaskReactor ` protocol. Here you'll receive the `SubstanceChange` callbacks passing a `FlaskReaction` instance describing the changes.

```swift    
    func flaskReactor(reaction: FlaskReaction) {
        
        reaction.on(AppState.prop.counter) { (change) in
            print("counter = \(substance.state.counter)")
        }
        reaction.on(AppState.prop.text) { (change) in
            print("text = \(substance.state.text)")
        }
        
    }

```

> Attach a `FlaskClass` instance to this ViewController

```swift    
    override func viewDidLoad() {
        
        AttachFlaskReactor(to:self, mixing:[substance])
        produceTestReaction()
    }
    
```

> Mix the `Substance` properties


```swift      
    
    func produceTestReaction(){
        
        GetFlaskReactor(at:self)
            .toMix(self.substance) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance) { (substance) in
                substance.prop.text = "changed!"
            }.andReact()
        
    }

}
```
The above is a basic showcase of Flask high-level API. Other things to consider:

* `Substance.state` is a read only property and it's protected during the `mix()` operatons.
* While `mixing()` you would mutate the state using the `Substance.prop` accessor as `Substance.state` won't be available until the mix operation completes.
* Using `AttachFlaskReactor` creates a managed `Flask` instance that is *automatically disposed* when its owner becomes `nil`.  

Also keep in mind that:
 
* It's possible to instantiate Flask using a substances array: `AttachFlaskReactor(to:self, mixing:[app,settings,login])`
* These global functions are just idiomatic suggar and a  public low-level API is also available for more granular control.
* When needed you may call `DetachFlaskReactor(from:)` to immediately dispose your Flask.

## Fluxor Style Sample

```
//TODO
```

## Why Flask?

Flask implements both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) patterns through a unified architecture. Aditionally provides unique features not found in similar frameworks:

* Chain Reactions 
* Binding multiple stores
* Reduce changes with nested keys
* Flux locks and exclusive dispatch
* Automatic archiving to `UserDefaults`
* Managed attachments with automatic disposal
* Friendly high-level API
* Access to low-level API for more granular control
* Mixed use of both Redux and Fluxor patterns



## CocoaPods

If you use [CocoaPods](https://cocoapods.org/pods/Flask) to manage your dependencies, simply add **Flask** to your `Podfile`:

```
pod 'Flask'
```

And then import the module

```
import Flask
```
## Sample Project

A sample project is available in this repo inside the folder: 

* FlaskSample/

Make sure to run `Pod install` to create your workspace.

## Test Cases

The above sample project also ships with dozes of test cases as standard Xcode test units. It's a great source to learn more implementation patterns.

These tests are also automatically run with Travis-CI on each deployment and you can check the health status above for peace of mind.
   
## More Examples

More practical examples are on the works and we would love to  feature yours!

```
// Coming soon
```


## Guides

```
Coming Soon
```

## Documentation

Jazzy generated documentation available here:

[Documentation](https://eonfluxor.github.io/flask/)

> *Please note the documentation is work in progress.*


## Have a question?
If you need any help, please visit our GitHub issues. Feel free to file an issue if you do not manage to find any solution from the archives.

You can also reach us at: 

`eonfluxor@gmail.com `

## About

**Flask** was created by [Hassan Uriostegui](http://linkedin.com/in/hassanvfx) 
