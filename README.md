## Build Status

|**Branch**| **Status** |
|---|---|
|**master** |[![Bunch Status](https://travis-ci.org/DynamicThreads/Dispatch.svg?branch=master)](https://travis-ci.org/DynamicThreads/Dispatch)|
|**develop** |[![Bunch Status](https://travis-ci.org/DynamicThreads/Dispatch.svg?branch=develop)](https://travis-ci.org/DynamicThreads/Dispatch)|

## Dispatch

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
![Platforms](https://img.shields.io/cocoapods/p/Dispatch.svg?style=flat)
[![License](https://img.shields.io/cocoapods/l/Dispatch.svg)](https://github.com/DynamicThreads/Dispatch/master/LICENSE)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
![Podspec](https://img.shields.io/cocoapods/v/Dispatch.svg)


[![codebeat badge](https://codebeat.co/badges/b1709704-b1b6-40fa-a38f-0962f72aa264)](https://codebeat.co/projects/github-com-dynamicthreads-dispatch)
[![codecov](https://codecov.io/gh/DynamicThreads/Dispatch/branch/master/graph/badge.svg)](https://codecov.io/gh/DynamicThreads/Dispatch)

## Installation

#### CocoaPods

Dispatch is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Dispatch'
```

## Carthage
----------------

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Dispatch into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "DynamicThreads/Dispatch"
```

Run `carthage update` to fetch the Dispatch library and drag into your Xcode project.


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

- [X] Carthage compatible
- [X] Chainable methods
- [X] Travis CI
- [X] Unit Tests
- [ ] More examples

## Authors

- João Mourato, joao.armourato@gmail.com

- Gabriel Peart

## License

Dispatch is available under the MIT license. See the LICENSE file for more info.