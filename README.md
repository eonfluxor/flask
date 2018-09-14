 <p align="center"> 
    <img src="http://res.cloudinary.com/dmje5xfzh/image/upload/c_scale,r_60,w_280/v1536646955/static/Flask-logo.png" alt="alternate text">
 </p>
 

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Flask.svg)](#cocoapods) 
[![GitHub release](https://img.shields.io/github/release/eonfluxor/flask.svg)](https://github.com/eonfluxor/flask/releases) 
![Swift 4.0](https://img.shields.io/badge/Swift-4.1-orange.svg) 
![platforms](https://img.shields.io/cocoapods/p/Flask.svg)
[![Build Status](https://travis-ci.org/eonfluxor/flask.svg?branch=master)](https://travis-ci.org/eonfluxor/flask)

**Supported Swift Versions:** Swift 4.0

*This is a pre-release. The code is stable but documentation is WIP.*

# What is Flask Reactor?
Flask is a multiplatform **[ iOS | OSX | tvOS ]** implementation of the unidirectional data flow architecture in Swift. Flask offers a *friendly API* and a robust feature set. 

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


## Motivation

Flask should deliver the most robust feature set accessible through the most friendly API.

With this in mind, Flask goes beyond the novelty of this architecture to develop an expressive API borrowing elemental science concepts to craft a framework that is easy to understand through analogies of the physical world.

All this while the core technology offers a unified implementation of both the `Redux` and `Fluxor` patterns while delivering advanced features not available in other frameworks (such as locks and nested keys reduction). 

## Why Flask?

Flask provides unique features not found in similar frameworks:

* Chain reactions 
* Binding multiple stores
* Dictionary reduction supporting nested keys
* Flux locks and exclusive dispatch
* Automatic archiving to `UserDefaults`
* Managed attachment with automatic disposal
* Friendly high-level API
* Access to low-level API for more granular control
* Mixed use of both Redux and Fluxor patterns

## CocoaPods

If you use [CocoaPods](https://cocoapods.org/pods/Flask) , simply add **Flask** to your `Podfile`:

```
pod 'Flask'
```

And then import the module

```
import Flask
```


## Redux Style

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

> Implement the `FlaskReactor ` protocol. Here you'll receive the `SubstanceChange` callbacks passing a `FlaskReaction` instance describing the changes.

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

* `Substance.state` is a read-only property and it's protected during the `mix()` operation.
* While `mixing()` you would mutate the state using the `Substance.prop` accessor as `Substance.state` won't be available until the mix operation completes.
* Using `AttachFlaskReactor` creates a managed `Flask` instance that is *automatically disposed* when its owner becomes `nil`.  

Also keep in mind that:
 
* It's possible to instantiate Flask using a substances array: `AttachFlaskReactor(to:self, mixing:[app,settings,login])`
* These global functions are just idiomatic sugar and a  public low-level API is also available for more granular control.
* When needed you may call `DetachFlaskReactor(from:)` to immediately dispose your Flask.

## Fluxor Style

The fluxor pattern requires more setup but it's very convenient for shared substances.

> Define the Global `FluxMixer` (aka dispatch actions)

```swift
enum EnvMixers : FluxMixer {
    case Login
    case Logout
}
```

> Define a `Substance` `State`

```swift
struct AppState : State {
    
    enum prop : StateProp{
        case counter, title, asyncResult
    }
    
    var counter = 0
    var title = ""
    
    var object:FlaskNSRef? // reference to NSObject
    var map:FlaskDictRef?  // NSDictionary wrapper for nested changes
    
    var _internal = "use underscore to ignore var changes"
    
}
```

> Define a `Substance` combining `State` and global `FluxMixer`

```swift
class AppReactiveSubstance : ReactiveSubstance<AppState,EnvMixers> {
    
    override func defineMixers(){
        
        define(mix: .Login) { (payload, react, abort)  in
            self.prop.title = "signed"
            react()
        }
    }  
}

```

> Define a Substance Singletons


```swift
class Subs {
    static let appReactive = AppReactiveSubstance()
}
```

> Implement the `FlaskReactor` protocol in a ViewController (or any other object)

```swift
class ViewController: UIViewController, FlaskReactor  {
       
    func flaskReactor(reaction: FlaskReaction) {
             
      // if no name conflicts the .at(store) may be skipped
        reaction.on(AppState.prop.title) { (change) in
            print("global title = \(Subs.appReactive.state.title)")
        }
        
    }
}
```

> And attach a `FlaskClass` instance in your configuration initializer 

```swift    
    override func viewDidLoad() {
        
        AttachFlaskReactor(to:self, mixing:[substance])
      
    }
    
```

> Apply the global `FluxMixer` (aka dispatch action) from anywhere in the app

```swift
 MixSubstances(with:EnvMixers.Login)
 
 //or
 
 Flask.applyMixer(EnvMixers.Login, payload:["user":userObject])
 Flask.applyMixer(EnvMixers.Logout)
```
As you can notice the main difference are:

* Required definition of global `FluxMixer` (aka dispatch actions).
* Required definition of a `ReactiveSubstance`.
* Required to `defineMixers()` in the `ReactiveSubstance`.
* Required definition of a global singleton to access your `ReactiveSusbtance` from anywhere in the app.

The above setup allows to easily call ` MixSubstances(with:)` (aka ` Flask.applyMixer()`  from anywhere in the application to trigger the `FluxMixer` reactions in all the `ReactiveSubstance` instances implementing it.


## Sample Project

A sample project is available in this repo inside the folder: 

* FlaskSample/

Make sure to run `Pod install` to create your workspace.

The sample application implements both patterns simultaneously for further reference.

## Test Cases

The above sample project also ships with dozens of test cases as standard Xcode test units. It's a great source to learn more implementation patterns.

These tests are also automatically run with Travis-CI on each deployment and you can check the health status above for peace of mind.
   
## More Examples

More practical examples are in the works and we would love to  feature yours!

### Chain Reaction
```
// Coming soon
```

### Locks
```
// Coming soon
```

### Mixing Lock
```
// Coming soon
```

### Nested Keys
```
// Coming soon
```

### Archiving
```
// Coming soon
```
### Low level API
```
// Coming soon
```

## Guides

Please review the above examples for Redux or Fluxor style implementations. More coming soon.


## Discussion

#### Why mixing Fluxor and Redux?

It's simple, with  `ReactiveSubstance` classes you have the ability to make them all react in the same way to global `FluxMixer` events (like login/logout) while keeping the flexibility of applying more contextual transformations using Redux style "inline" transformations.

For instance, an App `ReactiveSubstance` make sense as it would react to global events like log out or navigation. Also, it's a perfect candidate to be archived enabling `Substance.shouldArchive` to act as a basic an in-app data storage. Still, you can use this App substance in any `FlaskReactor` implementation and further apply Redux style transformations in a more particular context.

All this while the framework guarantees the unidirectional flow integrity despite mixing global `FluxMixer` events or local `Flask.mix` reactions.

#### Why Substance instead of Store?

> TODO

#### How many Substances should I have?

> TODO

#### Advantages of Substance Archive.

> TODO

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
