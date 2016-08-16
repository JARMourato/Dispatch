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

import XCTest

@testable import DispatchFramework

class DispatchTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testBasicAsync() {
    let expectation = expectationWithDescription("Wait for Dispatch Async")
    let delay = 1.0

    Dispatch.after(delay) {
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(delay, handler: nil)
  }

  func testBasicChain() {
    let expectationAfter = expectationWithDescription("Wait for Dispatch Chain Async After")
    let expectationAsync = expectationWithDescription("Wait for Dispatch Chain Async Main")
    let delay = 1.0
    var operation: Int = 1
    var hasPassedByAsync = false

    Dispatch.after(delay) {
      if hasPassedByAsync {
        XCTFail("This should be the first block to be executed")
        return
      }
      XCTAssertEqual(operation, 1, "This should be the first block to be executed")
      operation = 2
      expectationAfter.fulfill()
    }.async {
      hasPassedByAsync = true
      XCTAssertEqual(operation, 2, "This should be the second block to be executed")
      expectationAsync.fulfill()
    }
    waitForExpectationsWithTimeout(delay + 1, handler: nil)
  }

}
