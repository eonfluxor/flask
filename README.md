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
   
## Gists

More practical examples are in the works and we would love to  feature yours!

### Chain Reaction

A call to  `mix()` ( aka `toMix()` ) returns a Flask `ChainReaction` instance that can be futher chained until resolved.  A `ChainReaction` has the following methods:

* mix(substance:)
* react()
* abort()

To continue the chain, just call mix (or any of its aliases) again. You must call `react()` or `abort()` (or its aliases) in order to resolve the transaction (otherwise your Flask will fail to perform further mix transactions).

> Using the high-level API

```swift
 GetFlaskReactor(at:self)
            .toMix(self.substanceA) { (substance) in
                substance.prop.counter = 10
                
            }.with(self.substanceB) { (substance) in
                substance.prop.text = "text"
                
            }.andReact()
```
> Using the low level API

```swift
   Flask
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

### Nested Keys

It's really easy to observe changes in nested keys: 

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
 flask.mix(substance){ (substance) in
 
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

```
struct AppState : State {
    
    var _internal = "`_` use this prefix for internal vars "
    
}
```
This could be useful if for whatever reason you are performing additional computations in your state. 

### Low-level API

Behind the scenes, most high-level functions rely on calling stating methods on the main `Flask` class.

You can see them all [here](file:///Users/hassanvfx/projects/eonflux/flask/docs/Classes/Flask.html):


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

attachFlask(to:mixing:)
detachFlask(from:)
```

You can also access the `FlaskManager` that holds all the attached `FlaskClass` instances

```swift
flasks
purge()
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

#### Advantages of Substance Archiving

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
