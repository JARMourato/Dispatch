//
//  Helpers.swift
//  Dispatch
//
//  Created by João Mourato on 08/06/16.
//
//

import Foundation

public extension Dispatch {
  
  static func async(closure: DispatchClosure) -> Dispatch {
    return async(Queue.main, closure: closure)
  }
  
  public func async(closure: DispatchClosure) -> Dispatch {
    return async(Queue.main, closure: closure)
  }
  
  static func asyncBackground(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalBackground, closure: closure)
  }
  
  func asyncBackground(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalBackground, closure: closure)
  }
  
  static func asyncUtility(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalUtility, closure: closure)
  }
  
  func asyncUtility(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalUtility, closure: closure)
  }
  
  static func asyncUserInitiated(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalUserInitiated, closure: closure)
  }
  
  func asyncUserInitiated(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalUserInitiated, closure: closure)
  }
  
  static func asyncUserInteractive(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalUserInteractive, closure: closure)
  }
  
  func asyncUserInteractive(closure: DispatchClosure) -> Dispatch {
    return async(Queue.globalUserInteractive, closure: closure)
  }
  
}

public extension Queue {
  public static var globalUserInteractive : dispatch_queue_t { return global(Queue.Priority.userInteractive) }
  public static var globalUserInitiated : dispatch_queue_t { return global(Queue.Priority.userInitiated) }
  public static var globalUtility : dispatch_queue_t { return global(Queue.Priority.utility) }
  public static var globalBackground : dispatch_queue_t { return global(Queue.Priority.background) }
}
