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

fileprivate var getTimeout: (_ time: TimeInterval) -> Int64 = { Int64($0 * Double(NSEC_PER_SEC)) }
fileprivate var dispatchTimeCalc: (TimeInterval) -> (DispatchTime) = { DispatchTime.now() + Double(getTimeout($0)) / Double(NSEC_PER_SEC) }

//MARK: - Queue

public enum Queue {
  public enum Atribute {
    static var concurrent: DispatchQueue.Attributes = DispatchQueue.Attributes.concurrent
    static var serial: DispatchQueue.Attributes = []
  }

  public enum Priority {
    static var userInteractive: DispatchQoS.QoSClass = DispatchQoS.QoSClass.userInteractive
    static var userInitiated: DispatchQoS.QoSClass = DispatchQoS.QoSClass.userInitiated
    static var utility: DispatchQoS.QoSClass = DispatchQoS.QoSClass.utility
    static var background: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background
  }

  public static var main: DispatchQueue {
    return DispatchQueue.main
  }

  public static var global: (DispatchQoS.QoSClass) -> DispatchQueue = { priority in
    return DispatchQueue.global(qos: priority)
  }

  public static var custom: (String, DispatchQueue.Attributes) -> DispatchQueue = { identifier, attributes in
    return DispatchQueue(label: identifier, attributes: attributes)
  }

}

//MARK: - Group

public struct Group {
  public let group: DispatchGroup = DispatchGroup()
  private var onceToken: Int32 = 0

  public func enter() {
    group.enter()
  }

  public func leave() {
    group.leave()
  }

  public mutating func enterOnce() {
    enter()
    onceToken = 1
  }

  @discardableResult
  public mutating func leaveOnce() -> Bool {
    guard OSAtomicCompareAndSwapInt(1, 0, &onceToken) else { return false }
    leave()
    return true
  }

  @discardableResult
  public func async(_ queue: DispatchQueue, closure: @escaping DispatchClosure) -> Group {
    queue.async(group: group) {
      autoreleasepool(invoking: closure)
    }
    return self
  }

  public func notify(_ queue: DispatchQueue, closure: @escaping DispatchClosure) {
    group.notify(queue: queue) {
      autoreleasepool(invoking: closure)
    }
  }

  @discardableResult
  public func wait() -> DispatchTimeoutResult {
    return group.wait(timeout: DispatchTime.distantFuture)
  }

  @discardableResult
  public func wait(_ timeout: TimeInterval) -> DispatchTimeoutResult {
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

  @discardableResult
  public func signal() -> Int {
    return semaphore.signal()
  }

  @discardableResult
  public func wait() -> DispatchTimeoutResult {
    return semaphore.wait(timeout: DispatchTime.distantFuture)
  }

  @discardableResult
  public func wait(_ timeout: TimeInterval) -> DispatchTimeoutResult {
    return semaphore.wait(timeout: dispatchTimeCalc(timeout))
  }

}

//MARK: - Dispatch
//MARK: - Main structure

public struct Dispatch {
  fileprivate let currentItem: DispatchWorkItem
  fileprivate init(_ closure: @escaping DispatchClosure) {
    let item = DispatchWorkItem(flags: DispatchWorkItemFlags.inheritQoS, block: closure)
    currentItem = item
  }
}

//MARK: - Chainable methods

public extension Dispatch {

  //MARK: - Static methods

  @discardableResult
  public static func async(_ queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
    let dispatch = Dispatch(closure)
    queue.async(execute: dispatch.currentItem)
    return dispatch
  }

  @discardableResult
  public static func sync(_ queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
    let dispatch = Dispatch(closure)
    queue.sync(execute: dispatch.currentItem)
    return dispatch
  }

  @discardableResult
  public static func after(_ time: TimeInterval, closure: @escaping DispatchClosure) -> Dispatch {
     return after(time, queue: Queue.main, closure: closure)
  }

  @discardableResult
  public static func after(_ time: TimeInterval, queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
    let dispatch = Dispatch(closure)
    queue.asyncAfter(deadline: DispatchTime.now() + Double(getTimeout(time)) / Double(NSEC_PER_SEC), execute: dispatch.currentItem)
    return dispatch
  }

  //MARK: - Instance methods

  @discardableResult
  public func async(_ queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
    return chainClosure(queue: queue, closure: closure)
  }

  @discardableResult
  public func after(_ time: TimeInterval, closure: @escaping DispatchClosure) -> Dispatch {
    return after(time, queue: Queue.main, closure: closure)
  }

  @discardableResult
  public func after(_ time: TimeInterval, queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
    return chainClosure(time, queue: queue, closure: closure)
  }

  @discardableResult
  public func sync(_ queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
    let syncWrapper: DispatchClosure = {
      queue.sync(execute: closure)
    }
    return chainClosure(queue: queue, closure: syncWrapper)
  }

  //MARK: - Private chaining helper method

  private func chainClosure(_ time: TimeInterval? = nil, queue: DispatchQueue, closure: @escaping DispatchClosure) -> Dispatch {
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

//MARK: - Non-Chainable Methods

public extension Dispatch {

  public static func barrierAsync(_ queue: DispatchQueue, closure: @escaping DispatchClosure) {
    queue.async(flags: .barrier, execute: closure)
  }

  public static func barrierSync(_ queue: DispatchQueue, closure: DispatchClosure) {
    queue.sync(flags: .barrier, execute: closure)
  }

  public static func apply(_ iterations: Int, queue: DispatchQueue, closure: @escaping DispatchApplyClosure) {
    queue.async {
        DispatchQueue.concurrentPerform(iterations: iterations, execute: closure)
    }
  }

  public static func time(_ timeout: TimeInterval) -> DispatchTime {
    return dispatchTimeCalc(timeout)
  }

  public static var group: Group {
    return Group()
  }

  public static func semaphore(_ value: Int = 0) -> Semaphore {
    return Semaphore(value: value)
  }

}

//MARK: - Block methods

public extension Dispatch {
  public func cancel() {
    currentItem.cancel()
  }

  @discardableResult
  public func wait() -> DispatchTimeoutResult {
    return currentItem.wait(timeout: DispatchTime.distantFuture)
  }

  @discardableResult
  public func wait(_ timeout: TimeInterval) -> DispatchTimeoutResult {
    return currentItem.wait(timeout: dispatchTimeCalc(timeout))
  }
}
