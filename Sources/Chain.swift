/*
 The MIT License (MIT)
 
 Copyright (c) 2016 DynamicThreads
 
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

public protocol Chain {
  func async(queue: dispatch_queue_t, closure: DispatchClosure) -> Chain
  func async(closure: DispatchClosure) -> Chain
  func sync(queue: dispatch_queue_t, closure: DispatchClosure) -> Chain
  func after(time: NSTimeInterval, closure: DispatchClosure) -> Chain
  func after(time: NSTimeInterval, queue: dispatch_queue_t, closure: DispatchClosure) -> Chain
}

internal class ChainStack: Chain, Synchronous {
  
  var chainedClosures : [DispatchClosure] = [] {
    didSet {
      if oldValue.count < chainedClosures.count && !running { // new closure added and not running
        syncAccess{ running = true }
        runNextClosure()
      }
    }
  }
  var running : Bool = false
  
  private func push(closure: DispatchClosure) {
    syncAccess { chainedClosures.append(closure) }
  }
  
  private func popFirst() -> DispatchClosure? {
    return syncAccess { () -> (DispatchClosure?) in
      guard chainedClosures.count > 0 else { return nil }
      return chainedClosures.removeFirst()
    }
  }
  
  private func runNextClosure() {
    guard let nextClosure = popFirst() else {
      syncAccess { running = false }
      return
    }
    nextClosure()
    self.runNextClosure()
  }
  
  internal func newClosure(closure: (Void)->(Void)) -> Chain {
    push(closure)
    return self
  }

}

extension ChainStack {
  
  func async(queue: dispatch_queue_t, closure: DispatchClosure) -> Chain {
    push {
      Dispatch.async(queue, closure: closure)
    }
    return self
  }
  
  func async(closure: DispatchClosure) -> Chain {
    return async(Queue.main, closure: closure)
  }
  
  func sync(queue: dispatch_queue_t, closure: DispatchClosure) -> Chain {
    push {
      Dispatch.sync(queue, closure: closure)
    }
    return self
  }
  
  func after(time: NSTimeInterval, queue: dispatch_queue_t, closure: DispatchClosure) -> Chain {
    push {
      Dispatch.after(time, queue: queue, closure: closure)
    }
    return self
  }
  
  func after(time: NSTimeInterval, closure: DispatchClosure) -> Chain {
    return after(time, queue: Queue.main, closure: closure)
  }
  
}
