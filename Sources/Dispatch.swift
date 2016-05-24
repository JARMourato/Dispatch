/*
 The MIT License (MIT)
 
 Copyright (c) 2016 João Mourato
 
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

public typealias DispatchClosure = (Void)->(Void)
public typealias DispatchApplyClosure = (Int)->(Void)

internal func getTimeout(time: NSTimeInterval) -> Int64 { return Int64(time * Double(NSEC_PER_SEC)) }

internal var dispatch_time_calc : (NSTimeInterval)->(dispatch_time_t) = { dispatch_time(DISPATCH_TIME_NOW, getTimeout($0)) }

public enum Queue{
  public enum Atribute {
    static var concurrent : dispatch_queue_attr_t = DISPATCH_QUEUE_CONCURRENT
    static var serial : dispatch_queue_attr_t = DISPATCH_QUEUE_SERIAL
  }
  
  public enum Priority {
    static var userInteractive : Int = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
    static var userInitiated : Int = Int(QOS_CLASS_USER_INITIATED.rawValue)
    static var utility : Int = Int(QOS_CLASS_UTILITY.rawValue)
    static var background : Int = Int(QOS_CLASS_BACKGROUND.rawValue)
  }
  
  public static var main : dispatch_queue_t {
    return dispatch_get_main_queue()
  }
    
  public static var global : (dispatch_queue_priority_t) -> dispatch_queue_t = { priority in
    return dispatch_get_global_queue(priority, 0)
  }
    
  public static var custom : (String, dispatch_queue_attr_t) -> dispatch_queue_t = { identifier, attribute in
    return dispatch_queue_create(identifier, attribute)
  }
}

public struct Group {
  public let group : dispatch_group_t = dispatch_group_create()
  private var onceToken : Int32 = 0
  
  public func enter() {
    dispatch_group_enter(group)
  }
    
  public func leave() {
    dispatch_group_leave(group)
  }
    
  public mutating func enterOnce() {
    enter()
    onceToken = 1
  }
    
  public mutating func leaveOnce() -> Bool {
    guard OSAtomicCompareAndSwapInt(1, 0, &onceToken) else { return false }
    leave()
    return true
  }
    
  public func async(queue: dispatch_queue_t, closure: DispatchClosure) -> Group {
    dispatch_group_async(group, queue) {
      autoreleasepool(closure)
    }
    return self
  }
    
  public func notify(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_group_notify(group, queue) {
      autoreleasepool(closure)
    }
  }
    
  public func wait() {
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
  }
    
  public func wait(timeout: NSTimeInterval) -> Int {
    return dispatch_group_wait(group, dispatch_time_calc(timeout))
  }
  
}

public struct Semaphore {
  private let value : Int
  let semaphore : dispatch_semaphore_t
  
  public init(value: Int) {
    self.value = value
    semaphore = dispatch_semaphore_create(value)
  }
    
  public init() {
    self.init(value: 0)
  }
    
  public func signal() -> Int {
    return dispatch_semaphore_signal(semaphore)
  }
    
  public func wait() {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
  }
    
  public func wait(timeout: NSTimeInterval) -> Int {
    return dispatch_semaphore_wait(semaphore, dispatch_time_calc(timeout))
  }
  
}

public class Dispatch {
  static func async(closure: DispatchClosure) {
    async(Queue.main, closure: closure)
  }
    
  static func async(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_async(queue, closure)
  }
    
  static func sync(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_sync(queue, closure)
  }
    
  static func once(inout token: dispatch_once_t, closure: DispatchClosure) {
    dispatch_once(&token, closure)
  }
    
  static func after(time: NSTimeInterval, closure: DispatchClosure) {
     after(time, queue: Queue.main, closure: closure)
  }
    
  static func after(time: NSTimeInterval, queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, getTimeout(time)), queue, closure)
  }
    
  static func barrierAsync(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_barrier_async(queue, closure)
  }
    
  static func barrierSync(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_barrier_sync(queue, closure)
  }
    
  static func apply(iterations: Int, queue: dispatch_queue_t, closure: DispatchApplyClosure) {
    dispatch_apply(iterations, queue, closure)
  }
    
  static func time(timeout: NSTimeInterval) -> dispatch_time_t {
    return dispatch_time_calc(timeout)
  }
    
  static var group : Group {
    return Group()
  }
    
  static func semaphore(value : Int = 0) -> Semaphore {
    return Semaphore(value: value)
  }
  
}

//MARK: Helpers

public extension Queue {
  public static var globalUserInteractive : dispatch_queue_t { return global(Queue.Priority.userInteractive) }
  public static var globalUserInitiated : dispatch_queue_t { return global(Queue.Priority.userInitiated) }
  public static var globalUtility : dispatch_queue_t { return global(Queue.Priority.utility) }
  public static var globalBackground : dispatch_queue_t { return global(Queue.Priority.background) }
}