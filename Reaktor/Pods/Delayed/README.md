 <p align="center"> 
    <img src="https://res.cloudinary.com/dmje5xfzh/image/upload/v1536538700/static/kron-logo.png" alt="alternate text">
 </p>

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Delayed.svg)](#cocoapods) 
[![GitHub release](https://img.shields.io/github/release/eonfluxor/kron.svg)](https://github.com/eonfluxor/delay/releases) 
![Swift 4.0](https://img.shields.io/badge/Swift-4.1-orange.svg) 
![platforms](https://img.shields.io/cocoapods/p/Delayed.svg)
[![Build Status](https://travis-ci.org/eonfluxor/kron.svg?branch=master)](https://travis-ci.org/eonfluxor/kron)



# What is Kron?
**Kron** is a **NSTimer manager** offering **4 modes** through a unified api. Kron takes care of the involved implementation of NSTimers while ensuring a proper memory management with no extra effort:

1. `Kron.debounce`: Calls immediatly and reject calls until time out elapses
1. `Kron.debounceLast`: As `debounce` but also performs the last call after time out
1. `Kron.idle`: Performs the last call after not being called during the timeout interval
1. `Kron.watchdog`: As `idle` but allowing to be canceled with `watchDogCancel`

### Why Kron?


* Instead of returning a timer object, **Kron** manages the Timer instances internally through a [`KronKey` : `Timer`]  dictionary. This makes easy to call **Kron** from distant components or threads accesing the timers by their key value.


* The `KronKey` can be etiher a `String` struct or `AnyObject` instance.  If an object is passed the key is inferred from the object's pointer. Calling the methods with the same key causes all timer modes to be reset.


* As the intention is to facilitate calling **Kron** from distant implementations you can optional pass a context value `ctx`. A context can be `Any` struct or class instance and it's internally ***wrapped with a weak reference***  to prevent retain cycles. The context is then optionally passed to the timeOut closure.


### Gist

```
Kron.idle( 1.0 , key:"updateUI"){ (key,ctx) in
     
}
```

```
let context = 'userTap'
Kron.debounce( 1.0 , key:"updateUI", ctx: context){ (key,ctx) in
     print(ctx as! String) // userTap
}
```

```
//self.currentModel should be an AnyObject instance
Kron.watchdog( 10.0 , key:self.currentModel){ (key,ctx) in
           
}

//somewhere else
Kron.watchdogCancel(key:self.currentModel)

```

## Documentation

Self-generated documentation using jazzy and hosted in github available here:

[Documentation](https://eonfluxor.github.io/kron/)

## CocoaPods

If you use [CocoaPods][] to manage your dependencies, simply add
Kron to your `Podfile`:

```
pod 'Delayed', '~> 2.2.2'
```

And then import the module

```
import Delayed
```
   
   
## More Examples

Please review the test units for exhaustive implementation samples.

In all instances the timer will be reset by simply calling Kron with the same key. (See below `Static vs Instance` to learn more about the Static keyspace).

* **Idle Timer**


```
Kron.idle(1, key:"keyStrokes"){ (key,ctx) in
      print("performed after 1 second of inactivity")
}
```

* **Debouncer**

```
Kron.debounce(1, key:"Scroll"){ (key,ctx) in
      print("performed immediately and again no sooner than 1 second")
}
```

* **Debouncer and perform last**

```
Kron.debounceLast(1, key:"Scroll"){ (key,ctx) in
      print("performed immediately and again no sooner than 1 second")
      print("also performs the last call after 1 second of inactivity")
}
```

* **Watchdog**

```
Kron.wachtDog(10, key:"ApiResponse"){ (key,ctx) in
      print("performed  after 10 seconds unless canceled")

}

...

// Called somewhere else to abort the timeOut
Kron.wachtDogCancel("ApiResponse")

```

### Satic vs Instance

You can use the provided static functions. Internally **Kron** manages 4 singletons to prevent key collisions between the different modes:

```
//Debouncer
Kron.debounce

//Debouncing Last
Kron.debounceLast

//Idle
Kron.idle

//Watchdog
Kron.watchdog
```

Optionally you can instantiate **Kron** to manage your own keyspace in that given intance.

```
let myKron = Kron()
myKron( ...
```

## Have a question?
If you need any help, please visit our GitHub issues. Feel free to file an issue if you do not manage to find any solution from the archives.

You can also reach us at: 

`eonfluxor@gmail.com `

## About

**Kron** was originally built by [Hassan Uriostegui](http://linkedin.com/in/hassanvfx) as an objective-C framework. It's now released as a swift open source framework under the **Eonflux** collective. Check our other projects and join our *eon flux of innovaton* !
