## Examples

### Basic Demo

This example is shipped as part of the repo inside *FlaskSamples*.

>FlaskManifest.swift
    
```swift
import UIKit
import Flask

//Mark: - Global Reactive Substance Mixers

enum EnvMixers : FluxMixer {
    case Login
    case Logout
    case AsyncAction
}

enum NavMixers : FluxMixer {
    case Home
    case Settings
}

class Subs {
    
    static let app = AppSubstance()
    static let appReactive = AppReactiveSubstance()
}

```

>AppSubstance.swift

```swift
import UIKit
import Flask

//Mark: - A sample State definition

struct AppState : State {
    
    enum prop : StateProp{
        case counter, title, asyncResult
    }
    
    var counter = 0
    var title = ""
    var asyncResult = ""
    var object:FlaskNSRef?
    var map:FlaskDictRef?
    
    var _internal = "`_` use this prefix for internal vars "
    
}

//Mark: - A sample Reactive Substance

class AppReactiveSubstance : ReactiveSubstance<AppState,EnvMixers> {
    
    override func defineMixers(){
        
        define(mix: .Login) { (payload, react, abort)  in
            self.prop.title = "signed"
            react()
        }
        
        define(mix: .Logout) { (payload, react, abort)  in
           self.prop.title = "not signedd"
            react()
        }
        
        define(mix: .AsyncAction){ (payload, react, abort)  in
            self.prop.asyncResult = "async action pending"
            react()
        }
        
        define(mix: NavMixers.Home) { (payload, react, abort)  in
        
            abort()
        }
        
        define(mix: NavMixers.Settings) { (payload, react, abort)  in
            //TODO
            abort()
        }
    }
    
}

//Mark: - A sample Substance

class AppSubstance : Substance<AppState> {}
```
> ViewController.swift

```swift
import UIKit
import Flask

class ViewController: UIViewController, FlaskReactor  {
    
    //Mark: an inline Substance
    let substance = NewSubstance(definedBy: AppState.self)
    
    func flaskReactor(reaction: FlaskReaction) {
        
        //using the state enums
        reaction
            .at(substance)?
            .on(AppState.prop.counter) { (change) in
                print("local substance counter = \(substance.state.counter)")
        }
        
        
        //using prop as string
        reaction
            .at(Subs.appReactive)?
            .on("counter") { (change) in
                print("global substance counter = \(Subs.appReactive.state.counter)")
        }
        
        
        // if no name conflicts the .at(store) may be skipped
        reaction.on(AppState.prop.title) { (change) in
            print("global title = \(Subs.appReactive.state.title)")
        }
        
        reaction.on(AppState.prop.asyncResult) { (change) in
            print("global title = \(Subs.appReactive.state.asyncResult)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                //release when the operation is completed
                reaction.onLock?.release()
            });
        }
        
      
        
    }
    
    override func viewDidLoad() {
       
        AttachFlaskReactor(to:self, mixing:[substance, Subs.appReactive])
        produceTestReaction()
    }
    
    
    func produceTestReaction(){
        
        //dipose saved state between sessions for testing
        substance.shouldArchive = false
        
        
        MixSubstances(with: EnvMixers.Login)
        
        GetFlaskReactor(at:self)
            .toMix(self.substance) { (substance) in
                
                //local substance
                substance.prop.counter = 10
                
            }.with(Subs.appReactive) { (substance) in
                
                //global substance
                substance.prop.counter = 1000
                
            }.andReact()
        
        // a simple lock
        let lock = Flask.lock()
        
        // perform operations while the flux is paused
        // then release
        lock.release()
        
        // a mixer lock, blocks the normal flux
        // an immediately performs this mixer
        Flask.lock(withMixer: EnvMixers.AsyncAction)
        
        // logout won't be performed until the above lock is released (see reactor code)
        MixSubstances(with: EnvMixers.Logout)
    }   
}
```



