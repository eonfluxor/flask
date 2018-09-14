## Gists

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
   
    func flaskReactor(reaction: FlaskReaction) {
        
        reaction.on(AppState.prop.counter) { (change) in
            print("counter = \(substance.state.counter)")
        }
        reaction.on(AppState.prop.text) { (change) in
            print("text = \(substance.state.text)")
        }
        
    }
   
    override func viewDidLoad() {
        
        AttachFlaskReactor(to:self, mixing:[substance])
        produceTestReaction()
    }

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


## Fluxor Style

The fluxor pattern requires more setup but it's very convenient for shared substances.

> Substance.swift

```swift
enum EnvMixers : FluxMixer {
    case Login
    case Logout
}

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

class AppReactiveSubstance : ReactiveSubstance<AppState,EnvMixers> {
    
    override func defineMixers(){
        
        define(mix: .Login) { (payload, react, abort)  in
            self.prop.title = "signed"
            react()
        }
    }  
}

```

> Manifest

```swift
class Subs {
    static let appReactive = AppReactiveSubstance()
}
```

> ViewController

```swift
class ViewController: UIViewController, FlaskReactor  {
       
    func flaskReactor(reaction: FlaskReaction) {
             
      // if no name conflicts the .at(store) may be skipped
        reaction.on(AppState.prop.title) { (change) in
            print("global title = \(Subs.appReactive.state.title)")
        }
        
    }
}
 
    override func viewDidLoad() {
        
        AttachFlaskReactor(to:self, mixing:[substance])
      
    }

 MixSubstances(with:EnvMixers.Login)
 
 //or
 
 Flask.applyMixer(EnvMixers.Login, payload:["user":userObject])
 Flask.applyMixer(EnvMixers.Logout)
```

