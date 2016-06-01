//: Playground - noun: a place where people can play

import Foundation
import XCPlayground

public protocol Synchronous {}

public extension Synchronous where Self: AnyObject {
  public func syncAccess<T>(@noescape closure: ()->T) -> T{
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }
    return closure()
  }
}

internal func getTimeout(time: NSTimeInterval) -> Int64 { return Int64(time * Double(NSEC_PER_SEC)) }

internal var dispatch_time_calc : (NSTimeInterval)->(dispatch_time_t) = { dispatch_time(DISPATCH_TIME_NOW, getTimeout($0)) }

//public protocol Chain {
//
//}

internal class Chain: Synchronous { //Implement: Chain {
  
  var chainedClosures : [(Void) -> (Void)] = [] {
    didSet {
      if oldValue.count < chainedClosures.count && !running { // new closure added and not running
        syncAccess{ running = true }
        runNextClosure()
      }
    }
  }
  var running : Bool = false
  
  private init() {}
  
  internal func newClosure(closure: (Void)->(Void)) -> Chain {
    syncAccess { chainedClosures.append(closure) }
    return self
  }
  
  private func runNextClosure() {
    let nextClosure = syncAccess { () -> ((Void) -> (Void))? in
      guard chainedClosures.count > 0 else { return nil }
      return chainedClosures.removeFirst()
    }
    
    guard nextClosure != nil else {
      syncAccess { running = false }
      return
    }
  
    nextClosure?()
    self.runNextClosure()
  }
  
}

Chain().newClosure {
  print("Result : 1")
  }.newClosure {
    print("Result : 2")
  }.newClosure {
    print("Result : 3")
  }.newClosure {
    print("Result : 4")
  }.newClosure {
    print("Result : 5")
  }

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

