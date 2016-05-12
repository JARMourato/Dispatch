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

public enum Queue{
  
  public enum Atribute {
    static var Concurrent : dispatch_queue_attr_t = DISPATCH_QUEUE_CONCURRENT
    static var Serial : dispatch_queue_attr_t = DISPATCH_QUEUE_SERIAL
  }
  
  public enum Priority {
    static var UserInteractive : Int = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
    static var UserInitiated : Int = Int(QOS_CLASS_USER_INITIATED.rawValue)
    static var Utility : Int = Int(QOS_CLASS_UTILITY.rawValue)
    static var Background : Int = Int(QOS_CLASS_BACKGROUND.rawValue)
  }
  
  public static var Main : dispatch_queue_t {
    return dispatch_get_main_queue()
  }
  public static var Global : (dispatch_queue_priority_t) -> dispatch_queue_t = { priority in
    return dispatch_get_global_queue(priority, 0)
  }
  public static var Custom : (String, dispatch_queue_attr_t) -> dispatch_queue_t = { identifier, attribute in
    return dispatch_queue_create(identifier, attribute)
  }
}

public enum Dispatch {
  public typealias DispatchClosure = (Void)->(Void)
  
  static func Async(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_async(queue, closure)
  }
  static func Sync(queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_sync(queue, closure)
  }
  static func Once(inout token: dispatch_once_t, closure: DispatchClosure) {
    dispatch_once(&token, closure)
  }
  static func After(time: NSTimeInterval, queue: dispatch_queue_t, closure: DispatchClosure) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), queue, closure)
  }
}

//MARK: Helpers

public extension Queue {
  public static var GlobalUserInteractive : dispatch_queue_t { return Global(Queue.Priority.UserInteractive) }
  public static var GlobalUserInitiated : dispatch_queue_t { return Global(Queue.Priority.UserInitiated) }
  public static var GlobalUtility : dispatch_queue_t { return Global(Queue.Priority.Utility) }
  public static var GlobalBackground : dispatch_queue_t { return Global(Queue.Priority.Background) }
}
