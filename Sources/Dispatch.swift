/*
 The MIT License (MIT)

 Copyright (c) 2016 Swiftification

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

public typealias DispatchClosure = (Void) -> (Void)
public typealias DispatchApplyClosure = (Int) -> (Void)

fileprivate func getTimeout(_ time: TimeInterval) -> Int64 { return Int64(time * Double(NSEC_PER_SEC)) }
fileprivate var dispatchTimeCalc: (TimeInterval) -> (DispatchTime) = { DispatchTime.now() + Double(getTimeout($0)) / Double(NSEC_PER_SEC) }

//MARK: - Queue

public enum Queue {
  enum Atribute {
    static var concurrent: DispatchQueue.Attributes = DispatchQueue.Attributes.concurrent
    static var serial: DispatchQueue.Attributes = []
  }

  enum Priority {
    static var userInteractive: DispatchQoS.QoSClass = DispatchQoS.QoSClass.userInteractive
    static var userInitiated: DispatchQoS.QoSClass = DispatchQoS.QoSClass.userInitiated
    static var utility: DispatchQoS.QoSClass = DispatchQoS.QoSClass.utility
    static var background: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background
  }

  static var main: DispatchQueue {
    return DispatchQueue.main
  }

  static var global: (DispatchQoS.QoSClass) -> DispatchQueue = { priority in
    return DispatchQueue.global(qos: priority)
  }

  static var custom: (String, DispatchQueue.Attributes) -> DispatchQueue = { identifier, attributes in
    return DispatchQueue(label: identifier, attributes: attributes)
  }

}

//MARK: - Group

public struct Group {
  public let group: DispatchGroup = DispatchGroup()
  private var onceToken: Int32 = 0

  func enter() {
    group.enter()
  }

  func leave() {
    group.leave()
  }

  mutating func enterOnce() {
    enter()
    onceToken = 1
  }

  mutating func leaveOnce() -> Bool {
    guard OSAtomicCompareAndSwapInt(1, 0, &onceToken) else { return false }
    leave()
    return true
  }

  func async(_ queue: DispatchQueue, closure: DispatchClosure) -> Group {
    queue.async(group: group) {
      autoreleasepool(invoking: closure)
    }
    return self
  }

  func notify(_ queue: DispatchQueue, closure: DispatchClosure) {
    group.notify(queue: queue) {
      autoreleasepool(invoking: closure)
    }
  }

  func wait() -> DispatchTimeoutResult {
    return group.wait(timeout: DispatchTime.distantFuture)
  }

  func wait(_ timeout: TimeInterval) -> DispatchTimeoutResult {
    return group.wait(timeout: dispatchTimeCalc(timeout))
  }

}

//MARK: - Semaphore

public struct Semaphore {
  private let value: Int
  let semaphore: DispatchSemaphore

  init(value: Int) {
    self.value = value
    semaphore = DispatchSemaphore(value: value)
  }

  init() {
    self.init(value: 0)
  }

  func signal() -> Int {
    return semaphore.signal()
  }

  func wait() -> DispatchTimeoutResult {
    return semaphore.wait(timeout: DispatchTime.distantFuture)
  }

  func wait(_ timeout: TimeInterval) -> DispatchTimeoutResult {
    return semaphore.wait(timeout: dispatchTimeCalc(timeout))
  }

}

//MARK: - Dispatch
//MARK: Main structure

public struct Dispatch {
  fileprivate let currentItem: DispatchWorkItem
  fileprivate init(_ closure: DispatchClosure) {
    let item = DispatchWorkItem(flags: DispatchWorkItemFlags.inheritQoS, block: closure)
    currentItem = item
  }
}

//MARK: Chainable methods

public extension Dispatch {

  //MARK: Static methods

  static func async(_ queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    let dispatch = Dispatch(closure)
    queue.async(execute: dispatch.currentItem)
    return dispatch
  }

  static func sync(_ queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    let dispatch = Dispatch(closure)
    queue.sync(execute: dispatch.currentItem)
    return dispatch
  }

  static func after(_ time: TimeInterval, closure: DispatchClosure) -> Dispatch {
     return after(time, queue: Queue.main, closure: closure)
  }

  static func after(_ time: TimeInterval, queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    let dispatch = Dispatch(closure)
    queue.asyncAfter(deadline: DispatchTime.now() + Double(getTimeout(time)) / Double(NSEC_PER_SEC), execute: dispatch.currentItem)
    return dispatch
  }

  //MARK: Instance methods

  func async(_ queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    return chainClosure(queue: queue, closure: closure)
  }

  func after(_ time: TimeInterval, closure: DispatchClosure) -> Dispatch {
    return after(time, queue: Queue.main, closure: closure)
  }

  func after(_ time: TimeInterval, queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    return chainClosure(time, queue: queue, closure: closure)
  }

  func sync(_ queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    let syncWrapper: DispatchClosure = {
      queue.sync(execute: closure)
    }
    return chainClosure(queue: queue, closure: syncWrapper)
  }

  //MARK: Private chaining helper method

  private func chainClosure(_ time: TimeInterval? = nil, queue: DispatchQueue, closure: DispatchClosure) -> Dispatch {
    let newDispatch = Dispatch(closure)
    let nextItem: DispatchWorkItem
    if let time = time {
      nextItem = DispatchWorkItem(flags: .inheritQoS) {
        queue.asyncAfter(deadline: DispatchTime.now() + Double(getTimeout(time)) / Double(NSEC_PER_SEC), execute: newDispatch.currentItem)
      }
    } else {
      nextItem = newDispatch.currentItem
    }
    currentItem.notify(queue: queue, execute: nextItem)
    return newDispatch
  }

}

//MARK: Non-Chainable Methods

public extension Dispatch {

  static func barrierAsync(_ queue: DispatchQueue, closure: DispatchClosure) {
    queue.async(flags: .barrier, execute: closure)
  }

  static func barrierSync(_ queue: DispatchQueue, closure: DispatchClosure) {
    queue.sync(flags: .barrier, execute: closure)
  }

  static func apply(_ iterations: Int, queue: DispatchQueue, closure: DispatchApplyClosure) {
    DispatchQueue.concurrentPerform(iterations: iterations, execute: closure)
  }

  static func time(_ timeout: TimeInterval) -> DispatchTime {
    return dispatchTimeCalc(timeout)
  }

  static var group: Group {
    return Group()
  }

  static func semaphore(_ value: Int = 0) -> Semaphore {
    return Semaphore(value: value)
  }

}

//MARK: Block methods

public extension Dispatch {
  func cancel() {
    currentItem.cancel()
  }

  func wait() -> DispatchTimeoutResult {
    return currentItem.wait(timeout: DispatchTime.distantFuture)
  }

  func wait(_ timeout: TimeInterval) -> DispatchTimeoutResult {
    return currentItem.wait(timeout: dispatchTimeCalc(timeout))
  }
}
