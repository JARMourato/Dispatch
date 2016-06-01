# Dispatch

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
![Platforms](https://img.shields.io/cocoapods/p/Dispatch.svg?style=flat)

![Podspec](https://img.shields.io/cocoapods/v/Dispatch.svg)
[![License](https://img.shields.io/cocoapods/l/Dispatch.svg)](https://github.com/JARMourato/Dispatch/master/LICENSE)

[![codebeat badge](https://codebeat.co/badges/b1709704-b1b6-40fa-a38f-0962f72aa264)](https://codebeat.co/projects/github-com-jarmourato-dispatch)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation

#### CocoaPods

Dispatch is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Dispatch'
```

And then simply

``` swift
import DispatchFramework
```

And your good to go!

#### Manually

1. Download and drop ```Dispatch.swift``` anywhere you like in your project.  
2. That's it.

## Usage

### Basic

```swift
Dispatch.async(dispatch_get_main_queue()) {
  //Code to be run on the main thread
}
```

##### Or using the helpers provided by Dispatch.Queue enum 

```swift
Dispatch.async(Queue.main) {
  //Code to be run on the main thread
}
```

##### Or using the overloaded method to run on the main thread

```swift
Dispatch.async {
  //Code to be run on the main thread
}
```

### Types of Dispatch

#### Async

```swift
Dispatch.async(Queue.main) {
  //Code to be run on the main thread
}
```

#### Sync

```swift
let someCustomQueue = dispatch_queue_create("custom.queue.dispatch", DISPATCH_QUEUE_CONCURRENT)
Dispatch.sync(someCustomQueue) {
  //Code to be synchronously on someCustomQueue
}
```

#### After

```swift
Dispatch.after(1.0, queue: Queue.main) {
  //Code to be run on the main thread after 1 second
}
```
##### Or using the overloaded method to run on the main thread

```swift
Dispatch.after(1.0) {
  //Code to be run on the main thread after 1 second
}
```

#### Once

```swift
let token : dispatch_once_t
Dispatch.once(&token) {
  //Code to be run only once in App lifetime
}
```

### Queue Helpers

#### Main queue

```swift
let mainQueue = Queue.main 
```

#### Custom queue

```swift
let customConcurrentQueue = Queue.custom("custom.concurrent.queue.dispatch", Queue.Atribute.concurrent)
let customSerialQueue = Queue.custom("custom.serial.queue.dispatch", Queue.Atribute.serial)
```

#### Global queues

```swift
let priority = 0 // or you use one of the Global priorities (ex: Queue.Priority.UserInteractive)
let globalQueue = Queue.global(priority)

// For comodity there are helpers for getting the Global queues

let globalUserInteractiveQueue = Queue.globalUserInteractive
let globalUserInitiatedQueue = Queue.globalUserInitiated
let globalUtilityQueue = Queue.globalUtility
let globalBackgroundQueue = Queue.globalBackground
```

## TODO

- [ ] Carthage compatible
- [ ] Chainable methods
- [ ] Unit Tests
- [ ] Travis CI
- [ ] More examples

## Authors

- João Mourato, joao.armourato@gmail.com

- Gabriel Peart

## License

Dispatch is available under the MIT license. See the LICENSE file for more info.
