# Guides

Step by step implementation following different styles. Keep in mind you can mix both patterns at any point.


## Redux Style

This is a gist of a basic ReSwift-like implementation. 

>Define Substance Initial `State`


*Substance.swift*

```swift
struct AppState : State{
    
    enum prop: StateProp{
        case counter, text
    }
    
    var counter = 0
    var text = ""
}
```

*ViewController.swift*

> Adopt `FlaskReactorChanges` protocol

```swift
class ViewController: UIViewController, FlaskReactorChanges  {
```

> Define a `Substance` instance

  
```swift  
    let substance = Flask.newSubstance(definedBy: AppState.self)
```

> Implement the `FlaskReactorChanges ` protocol. Here you'll receive the `SubstanceChange` callbacks passing a `FlaskReaction` instance describing the changes.

```swift    
    func flaskReactorChanges(reaction: FlaskReaction) {
        
        reaction.on(AppState.prop.counter) { (change) in
            print("counter = \(substance.state.counter)")
        }
        reaction.on(AppState.prop.text) { (change) in
            print("text = \(substance.state.text)")
        }
        
    }

```

> Attach a `Reactor` instance to this ViewController

```swift    
    override func viewDidLoad() {
        
        Flask.attachReactor(to:self, mixing:[substance])
        produceTestReaction()
    }
    
```

> Mix the `Substance` properties


```swift      
    
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
The above is a basic showcase of Flask high-level API. Other things to consider:

* `Substance.state` is a read-only property and it's protected during the `mix()` operation.
* While `mixing()` you would mutate the state using the `Substance.prop` accessor as `Substance.state` won't be available until the mix operation completes.
* Using `Flask.attachReactor` creates a managed `Flask` instance that is *automatically disposed* when its owner becomes `nil`.  

Also keep in mind that:
 
* It's possible to instantiate Flask using a substances array: `Flask.attachReactor(to:self, mixing:[app,settings,login])`
* These global functions are just idiomatic sugar and a  public low-level API is also available for more granular control.
* When needed you may call `Flask.detachReactor(from:)` to immediately dispose your Flask.

## Fluxor Style

The fluxor pattern requires more setup but it's very convenient for shared substances.

*FlaskManifest.swift*
> Define the Global `SubstanceMixer` (aka dispatch actions) and Substances singletons.


```swift
enum EnvMixers : SubstanceMixer {
    case Login
    case Logout
}

class Subs {
    static let appReactive = AppReactiveSubstance()
}

```

*Substance.swift*
> Define each `Substance` `State`

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

> Define a `Substance` combining `State` and global `SubstanceMixer`

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
*ViewController.swift*
> Implement the `FlaskReactorChanges` protocol in a ViewController (or any other object)

```swift
class ViewController: UIViewController, FlaskReactorChanges  {
       
    func flaskReactorChanges(reaction: FlaskReaction) {
             
      // if no name conflicts the .at(store) may be skipped
        reaction.on(AppState.prop.title) { (change) in
            print("global title = \(Subs.appReactive.state.title)")
        }
        
    }
}
```

> And attach a `Reactor` instance in your configuration initializer 

```swift    
    override func viewDidLoad() {
        
        Flask.attachReactor(to:self, mixing:[Subs.appReactive])
      
    }
    
```

*Anywhere*
> Apply the global `SubstanceMixer` (aka dispatch action) from anywhere in the app

```swift
 Flask.substances(reactTo:EnvMixers.Login)
 
 //or
 
 Flask.applyMixer(EnvMixers.Login, payload:["user":userObject])
 Flask.applyMixer(EnvMixers.Logout)
```
As you can notice the main difference are:

* Required definition of global `SubstanceMixer` (aka dispatch actions).
* Required definition of a `ReactiveSubstance`.
* Required to `defineMixers()` in the `ReactiveSubstance`.
* Required definition of a global singleton to access your `ReactiveSusbtance` from anywhere in the app.

The above setup allows to easily call ` Flask.substances(reactTo:)` (aka ` Flask.applyMixer()`  from anywhere in the application to trigger the `SubstanceMixer` reactions in all the `ReactiveSubstance` instances implementing it.

