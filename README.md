# Dispatch

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
![Platforms](https://img.shields.io/cocoapods/p/Dispatch.svg?style=flat)

![Podspec](https://img.shields.io/cocoapods/v/Dispatch.svg)
[![License](https://img.shields.io/cocoapods/l/Dispatch.svg)](https://github.com/JARMourato/Dispatch/master/LICENSE)

## Installation

Dispatch is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Dispatch'
```

## Usage

### Basic

```swift
Dispatch.Async(dispatch_get_main_queue()) {
  //Code to be run on the main thread
}

Or using the helpers provided by Dispatch.Queue enum 

Dispatch.Async(Queue.Main) {
  //Code to be run on the main thread
}
```

### Types of Dispatch

#### Async

```swift
Dispatch.Async(Queue.Main) {
  //Code to be run on the main thread
}
```

#### Sync

```swift
let someCustomQueue = dispatch_queue_create("custom.queue.dispatch", DISPATCH_QUEUE_CONCURRENT)
Dispatch.Sync(someCustomQueue) {
  //Code to be synchronously on someCustomQueue
}
```

#### After

```swift
Dispatch.After(1.0, queue: Queue.Main) {
  //Code to be run on the main thread after 1 second
}
```

#### Once

```swift
let token : dispatch_once_t
Dispatch.Once(&token) {
  //Code to be run only once in App lifetime
}
```

### Queue Helpers

#### Main queue

```swift
let mainQueue = Queue.Main 
```

#### Custom queue

```swift
let customConcurrentQueue = Queue.Custom("custom.concurrent.queue.dispatch", Queue.Atribute.Concurrent)
let customSerialQueue = Queue.Custom("custom.serial.queue.dispatch", Queue.Atribute.Serial)
```

#### Global queues

```swift
let priority = 0 // or you use one of the Global priorities (ex: Queue.Priority.UserInteractive)
let globalQueue = Queue.Global(priority)

// For comodity there are helpers for getting the Global queues

let globalUserInteractiveQueue = Queue.GlobalUserInteractive
let globalUserInitiatedQueue = Queue.GlobalUserInitiated
let globalUtilityQueue = Queue.GlobalUtility
let globalBackgroundQueue = Queue.GlobalBackground
```

## Author

João Mourato, joao.armourato@gmail.com

## License

Dispatch is available under the MIT license. See the LICENSE file for more info.
