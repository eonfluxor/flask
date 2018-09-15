# Guides

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
enum EnvMixers : SubstanceMixer {
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

