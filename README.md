 <p align="center"> 
    <img src="http://res.cloudinary.com/dmje5xfzh/image/upload/c_scale,r_60,w_280/v1536646955/static/Flask-logo.png" alt="alternate text">
 </p>
 

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Flask.svg)](#cocoapods) 
[![GitHub release](https://img.shields.io/github/release/eonfluxor/flask.svg)](https://github.com/eonfluxor/flask/releases) 
![Swift 4.0](https://img.shields.io/badge/Swift-4.1-orange.svg) 
![platforms](https://img.shields.io/cocoapods/p/Flask.svg)
[![Build Status](https://travis-ci.org/eonfluxor/reactor.svg?branch=master)](https://travis-ci.org/eonfluxor/flask)

# What is Flask Reactor?
Flask is a multiplatform **[ iOS | OSX | tvOS ]** implementation of the unidirectional data flow architecture in Swift. Flask offers a unique feature set beyond any similar frameworks through an *intuitive API*

While the Flux architecture is abstract, explaining Flask is easy:


 <p align="center"> 
    <img src="http://res.cloudinary.com/dmje5xfzh/image/upload/c_scale,w_620/v1536896631/static/scheme01.jpg">
 </p>
 
----

> **Flask** lets you **Mix** **Substances** and **React** to their **State** **Changes**

---

**Easy right?**

As such to preserve this natural intuition  `Flux Stores` are called a `Substance`. In Flask a `Substance` would represent any homogeneous data structure in your application *(ie. a feed, settings, or the application itself).*

Flask allows implementing both the [Redux](https://github.com/reactjs/redux) and [Fluxor](http://fluxxor.com/) patterns through a unified architecture. And although this integration may sound complicated, with Flask it's also easy to articulate:

----

> Flask lets you create **ReactiveSubstances** that react to environmental events called **Mixers** as well as plain **Substances** meant to be **Mixed** inside a particular **Flask**.

----

This is a direct analogy between the *Fluxor* pattern of `Reactive Stores` as a `ReactiveSubstance` and the *Redux* pattern of `Store Reducers`  as a plain `Substance`.

Using chemistry semantics is an intuitive way to approach the flux-reactive patterns. After all, the word `React` is itself defined [within the chemistry domain](https://dictionary.cambridge.org/us/dictionary/english/react).

# Table of Contents

- [Motivation](#motivation)
- [Why Flask?](#why-flask)
- [CocoaPods Installation](#cocoapods)
- [Architecture](#architecture)
- [Components](#components)
  - [Flask API](#flask-api)
  - [Substances](#substances)
  - [Mixers](#mixers)
  - [Reactor](#reactor)
  - [Flux](#flux)
- [Implementation](#implementation)
  - [Redux Style](#redux-style)
  - [Fluxor Style](#fluxor-style)
- [Special Features](#special-features)
  - [Chained Reactions](#chain-reactions)
  - [Flux Locks](#locks)
  - [Async Flux](#async-mixing-with-locks)
  - [Nested Structs](#nested-structs)
  - [NSObjects and Dictionaries](#nsobjects-and-dictionaries)
  - [Archiving](#archiving)
  - [Internal Properties](#internal-state-props)
  - [Low-Level API](#low-level-api)
- [Documentation](#documentation)

## Motivation
Flask Reactor is the foundation of a comprehensive toolbox defining the "Flask Pattern" as a way to create reactive applications in Apple's Swift platform. As such Flask delivers the most robust feature set through an intuitive API.

Flask goes beyond the novelty of the Reactive pattern to develop an expressive API using physical world analogies that are intuitive and easy to implement. All this while the core technology offers a unified implementation of both the `Redux` and `Fluxor` patterns and delivers advanced features not available in other frameworks (such as async-flux, locks and nested keys support). Such features are required for the development of higher-level frameworks (like the FlaskNavigation router or the FlaskAPI manager). 

> Despite its power Flask is as easy to implement as the most popular frameworks (ie. ReSwift). Code complexity is optional and progressive depending on your own implementations.

## Why Flask?

Flask provides unique features not found in similar frameworks:

* Chained mutations 
* Binding multiple stores 
* Structs reductions with nested keys
* NSObject pointer change reduction with `FlaskNSRef`
* NSDictionary and Dictionary reduction supporting nested keys 
* Flux locks and exclusive dispatch
* Automatic archiving to `UserDefaults`
* Managed attachment with automatic disposal
* Friendly high-level API
* Access to low-level API for more granular control
* Mixed use of both Redux and Fluxor patterns

## CocoaPods

If you use [CocoaPods](https://cocoapods.org/pods/Flask) , simply add **Flask** to your `Podfile`:

```ruby
pod 'Flask'
```

And then import the module

```swift
import Flask
```


# Architecture

![image](http://res.cloudinary.com/dmje5xfzh/image/upload/v1537117496/static/flas-flow01.jpg)

The above flowchart is an overview of the `Flask` pipeline.

* Green are `Reactor` components
* Blue are `Flux` components
* Pink are `Substance` components
* Yellow are `State` representations

## How it works?

These are the main components to interface with Flask:

* **Substances:** Any data structure in your application
* **Mixers:**  Transactional closures defining data mutations
* **Reactors:** Mixing Substances to produce reactions
* **Flux:**  The single unidirectional bus connecting the pipeline

# Components
### Flask API

These are the High-level API methods that you'll use more frequently:

```swift
// Managing your reactor instance
Flask.attachReactor(to:mixing:)
Flask.detachReactor(from:)
Flask.getReactor(at:)

// Dispatching a substancer mixer
Flask.substances(reactTo:payload:)

// Creating non-reactive substances
Flask.newSubstance(definedBy:)
Flask.newSubstance(definedBy:named:archive:)
```

Inspect these methods to learn more about the low-level API.

### Substances

Substances are minimally initialized with a `State` structure. ReactiveSubstances require an additional `SubstanceMixer` enumeration to facilitate handling environmental mixers.

* **Substance:** Easy to mutate using `Flask.mix`
* **ReactiveSubstance:** Like Substances but also observing global Substance Mixers.

Consider the following example:

> State

```swift
struct AppState : State {
    enum prop : StateProp{
        case counter
    }
    var counter = 0
}
```
> Substance

```swift
class Feed : Substance<AppState> {}
```
> Reactive Substance

```swift
enum Mixers : SubstanceMixer {
    case Login
}
class App : ReactiveSubstance<AppState,Mixers> {
    
    override func defineMixers(){
        define(mix: . Login) { (payload, react, abort)  in
            self.prop.counter = self.prop.counter + 1
            react()
        }
    }
    
}
```


### Mixers

Flask data mutations are performed using Mixers. A mixer is a transactional closure where you can access an modify given substance properties. There are two types of mixers:

* **Substance Mixer** These are declared as enumerations and passed as part of a `ReactiveSubstace` subclass definition. Internally the substance optionally subscribes to the cases where it needs to respond with internal data mutations inside a State Transaction context.
* **Flask Mixer** These can be used anywhere by accessing the substances bound to a given `Reactor` instance. Calling `reactor.mix( substance)`lets you declare a closure that includes a weak pointer to the requested substance in a State Transaction context where you can mutate the substance properties.

So while *Substance Mixers* can be applied across all substances sharing the same observers the *Flask Mixers* are intended for more specific transformations and had the advantage of mutating multiple substances through the use of a `ChainReaction`.

Consider the following samples:

> Global Substance Mixer. High-level API

```swift
  Flask.substances(reactTo:EnvMixers.Login, payload:["username":"foo"])
```

> Flask Mixer. High-level API

```
 Flask.getReactor(attachedTo:self)
            .mixing(self.substance!) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance!) { (substance) in
                substance.prop.text = "text"
            }.andReact()
```            

###  Reactor

The `Reactor` instances (or **reactor** for short) are initialized by the `ReactorManager` factory by passing a weak `owner` reference and an array of `[substances]`. Internally the framework takes care of lazily unbinding and disposing of the instances which `owner` has become nil. 

Each `Reactor` must define a handler closure where to receive the changes callbacks. You can see an example implementation here:

```swift
    let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
        
    reactor.handler={owner, reaction in
        reaction.on(AppState.prop.counter, { (change) in
            expectation.fulfill()
        })
    }
```
The above implementation is conviently wrapped using the `FlaskReactor` protocol in which case the implementation looks like this:

```swift
class ViewController: UIViewController, FlaskReactor  {

    func flaskReactions(reaction: FlaskReaction) {
        
        reaction.on(AppState.prop.counter) { (change) in
                print("counter = \(substance.state.counter)")
        }

  override func viewDidLoad() {
       
        Flask.attachReactor(to:self, mixing:[substance, Subs.appReactive])
        
    }
}
```
## Flux

In Flask, Flux is the unidirectional single dispatch bus that ensures that all mixing operations will be performed in an atomic way.

All this happens under the hood and you don't need to interface with Flux other than dispatching SubstanceMixer events.

However, it is possible to pause the Flux with a `FluxLock` and also perform exclusive mixes while the main flux is paused.  Even more, you can create asynchronous locks that would be released at a later time by actions performed in your reaction closure.

Read more about Locks below.

## New to Flux?

You can learn all about of Flux in this didactic article from Lin Clark.
[A cartoon guide to Flux](https://code-cartoons.com/a-cartoon-guide-to-flux-6157355ab207)

Also the official docs:
[Flux from facebook](https://facebook.github.io/flux/docs/overview.html)

# Implementation

Here is a quick reference on how to implement Flask Reactor in relation to the Redux and Fluxor pattern.

## Redux Style

This is a gist of a basic ReSwift-like implementation. 

> Substance.swift

```swift
struct AppState : State{
    
    enum prop: StateProp{
        case counter, text
    }
    
    var counter = 0
    var text = ""
}
```

> ViewController

```swift
class ViewController: UIViewController, FlaskReactor  {
   
    func flaskReactions(reaction: FlaskReaction) {
        
        reaction.on(AppState.prop.counter) { (change) in
            print("counter = \(substance.state.counter)")
        }
        reaction.on(AppState.prop.text) { (change) in
            print("text = \(substance.state.text)")
        }
        
    }
   
    override func viewDidLoad() {
        
        Flask.attachReactor(to:self, mixing:[substance])
        produceTestReaction()
    }

    func produceTestReaction(){
        
        Flask.getReactor(attachedTo:self)
            .mixing(self.substance) { (substance) in
                substance.prop.counter = 10
            }.with(self.substance) { (substance) in
                substance.prop.text = "changed!"
            }.andReact()
        
    }

}
```


## Fluxor Style

The fluxor pattern requires more setup but it's very convenient for shared substances.

> Manifest

```swift
enum EnvMixers : SubstanceMixer {
    case Login
    case Logout
}

class Subs {
    static let appReactive = AppReactiveSubstance()
}
```

> Substance.swift

```swift

struct AppState : State {
    
    enum prop : StateProp{
        case counter, title
    }
    
    var counter = 0
    var title = ""
    
}

class AppReactiveSubstance : ReactiveSubstance<AppState,EnvMixers> {
    
    override func defineMixers(){
        
        define(mix: .Login) { (payload, react, abort)  in
            self.prop.title = "signed"
            react()
        }
    }  
}

```



> ViewController

```swift
class ViewController: UIViewController, FlaskReactor  {
       
    func flaskReactions(reaction: FlaskReaction) {
             
        reaction.on(AppState.prop.title) { (change) in
            print("global title = \(Subs.appReactive.state.title)")
        }
        
    }
 
    override func viewDidLoad() {
        
        Flask.attachReactor(to:self, mixing:[Subs.appReactive])
        produceTestReaction()
    }

    func produceTestReaction(){
    
        Flask.substances(reactTo:EnvMixers.Login, payload:["username":"foo"])
 
     }
}
```

# Special Features

### Chain Reactions

A call to  `mix()` ( aka `mixing()` ) returns a Flask `ChainReaction` instance that can be futher chained until resolved.  A `ChainReaction` has the following methods:

* mix(substance:)
* react()
* abort()

To continue the chain, just call mix (or any of its aliases) again. You must call `react()` or `abort()` (or its aliases) in order to resolve the transaction (otherwise your Flask will fail to perform further mix transactions).

> Using the high-level API

```swift
 Flask.getReactor(attachedTo:self)
            .mixing(self.substanceA) { (substance) in
                substance.prop.counter = 10
                
            }.with(self.substanceB) { (substance) in
                substance.prop.text = "text"
                
            }.andReact()
```
> Using the low level API

```swift
   reactorInstance
       .mix(self.substanceA) { (substance) in
            substance.prop.counter = 10
            
        }.mix(self.substanceB) { (substance) in
            substance.prop.text = "text"
            
        }.react()
```
    
### Locks

When needed you can create a `FluxLock`. This will pause performing any mixes including `ReactiveSubstances` or `ChainReactions`.  You can create many Locks but you are responsible for releasing them all too reactive the flux.

```swift  
let lock = Flask.lock()
        
// perform operations while the flux is paused

lock.release()
```

### Async Mixing with Locks

Sometimes you need to perform a particular Mix operation that requires to pause all other mixings until the `FlaskReaction` is resolved.

Performing this is really simple using a `ReactiveSubstance` 

* Just create a `FluxLock` passing the name of your global EnvMixer. 
* Perform your `ReactiveSubstance` mix as usual
* Then in the `FluxReactor` inside the `FluxReaction` instance, you'll receive a pointer to your lock at  `reaction.onLock?` so you can release it.

Example:

> Request a Mix over a locked flux

```swift
        Flask.lock(withMixer: EnvMixers.AsyncAction)
```

> Async Release

```swift
 reaction.on(AppState.prop.asyncResult) { (change) in
 
            //pass the reaction to an async block 
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                //release when the operation is completed
                reaction.onLock?.release()
            });
            
   }
        
```



### Nested Structs

It's possible to use nested structs and Observe changes in them. The limitation around Structs is that all properties must conform to the Codable protocol.

If you need to support passing objects as top-level properties or nested, read below regarding Nested Dictionaries.

```swift

func testStruct(){
        
        let expectation = self.expectation(description: "testStruct")
        let expectation2 = self.expectation(description: "testStruct")
        let expectation3 = self.expectation(description: "testStruct")
        
        struct nestedTestStruct:Codable{
            var foo = "bar"
            var object = FlaskNSRef(NSObject())
        }
        
        struct testStruct:Codable{
            var counter = 10
            var nest = nestedTestStruct()
        }
        
        struct state : State{
            var info = testStruct()
        }
        
        let NAME = "substanceTest\( NSDate().timeIntervalSince1970)"
        let mySubstance = Flask.newSubstance(definedBy: state.self,named:NAME, archive:false)
        mySubstance.shouldArchive = true
        
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:mySubstance)

        
        reactor.handler = { owner, reaction in
            
            mySubstance.archiveNow()
            
            reaction.on("info", { (change) in
                expectation.fulfill()
            })
            reaction.on("info.counter", { (change) in
                expectation2.fulfill()
            })
            reaction.on("info.nest.foo", { (change) in
                expectation3.fulfill()
            })
        }
        
        reactor.mix(mySubstance) { (substance) in
            substance.prop.info.counter = 90
            substance.prop.info.nest.foo = "mutated"
            }.andReact()
        
        wait(for: [expectation,expectation2,expectation3], timeout: 2)
        
        let expectation4 = self.expectation(description: "must preserve after archive")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           
            let archivedSubstance = Flask.newSubstance(definedBy: state.self,named:NAME,archive:true)
            XCTAssert(archivedSubstance.state.info.nest.foo == "mutated", "Must preserve value")
            expectation4.fulfill()
        }
        
        wait(for: [expectation4], timeout: 4)
    }
```

### NSObjects and Dictionaries


**Objects and Archiving** : *Please consider that NSObjects are not serializable and will be mapped to `nil` by the `SubstanceSerializer`*

In case you need to observe changes in NSObject you can use `FlaskRef`. This will wrap your object inside a class that supports the Codable protocol required by your State struct.

When observing this keys you'll be notified whenever the object pointer to this object changes. This would allow you to observe changes in UI objects like UIViewController.

```swift
struct myState : State{
   var object = FlaskRef( NSObject() )
}

```

In case you need to deal with a hierarchy of nested objects the `FlaskDictRef` comes to the rescue.  Initialize an instance of this class with an NSDictionary and then you'll be able to observe changes on nested keys.

* In your state create a `FlaskDictRef` property
* Assign new values by wrapping your Dictionary in a `FlaskDictRef( Dictionary )`
* Observe changes in your nested keys using dot syntax.

Example:

> Create a FlaskDictRef property


```swift
struct AppState : State {
    
    enum prop : StateProp{
        case info
    }
    
    var info:FlaskDictRef?
}

```

> Assign values

```swift
 reactor.mix(substance){ (substance) in
 
          let data:NSDictionary = [
            "foo":"bar",
            "nest":[
                "data":"some"
            ]
            
        ]
        
       substance.prop.info = FlaskDictRef(data)
       
  }.react()

```

> Observe changes

```swift
 reaction.on("info.nest.data", { (change) in
      print(change.newValue()!)
 })
```

### Archiving

Archiving is a great alternative to SQL-Lite or CoreData when you don't need to perform queries or relational operations in your data. Consider that this feature relies on UserDefaults as storage destination.

By default, archiving is off. To Enable archiving you just need to pass two extra parameters to the `Substance` or `ReactiveSubstance` initializer:

```
let substance = MySubstanceClass(name:"uniqueName",archive:true)
```
The name has to be unique so make sure to use a proper naming convention for your app.

The substances are then archived after being ile for 2 seconds when changes are detected. It's possible to disable archiving after instantiation by using the property `Substance.shouldArchive`.

You can further customize the process by overriding any of the following methods in your Substances subclasses:

```swift
    override func archiveKeySpace()->String{
        return "1"
    }
    
    override func archiveKey()->String{
        return "Fx.\(archiveKeySpace()).\(name())"
    }
    
    override func archiveDelay()->Double{
        return 2.0
    }
    
    override func archiveDisabled()->Bool{
        return !shouldArchive
    }
```

### Internal state props

In case you want to ignore some State properties from being used in the changes reduction, just use the `_` prefix on the variable name:

```swift
struct AppState : State {
    
    var _internal = "`_` use this prefix for internal vars "
    
}
```
This could be useful if for whatever reason you are performing additional computations in your state. 

### Low-level API

Behind the scenes, most high-level functions rely on calling stating methods on the main `Flask` class.

You can see them all [here](file:///Users/hassanvfx/projects/eonflux/reactor/docs/Classes/Flask.html):


```swift
purgeFluxQueue()
purgeFlasks()

instance(attachedTo:mixing:)
instance(attachedTo:mixing:)

lock()
lock(withMixer:)
lock(withMixer:payload:)
removeLocks()

applyMixer(_:payload:)

attachReactor(to:mixing:)
detachReactor(from:)
```

You can also access the `ReactorManager` that holds all the attached `Reactor` instances

```swift
reactors
purge()
```

# Documentation

## Demo Project

A sample project is available in this repo inside the folder: 

* FlaskSample/

Make sure to run `Pod install` to create your workspace.

The sample application implements both patterns simultaneously for further reference.

## Test Cases

The above sample project also ships with dozens of test cases as standard Xcode test units. It's a great source to learn more implementation patterns.

These tests are also automatically run with Travis-CI on each deployment and you can check the health status above for peace of mind.
   
## Gists

More practical examples are in the works and we would love to feature yours!

## API Documentation
> *Please note the documentation is work in progress.*

Jazzy generated documentation available here: [Documentation](https://eonfluxor.github.io/reactor/)

## Have a question?
If you need any help, please visit our GitHub issues. Feel free to file an issue if you do not manage to find any solution from the archives.

You can also reach us at: 

`eonfluxor@gmail.com `

## About

**Flask** was created by [Hassan Uriostegui](http://linkedin.com/in/hassanvfx) 
