import Core
import XCTest

class LimitedArrayTest: XCTestCase {
  func testAppend() {
    XCTContext.runActivity(named: "Append") { _ in
      XCTContext.runActivity(named: "Up to the upper limit") { _ in
        var array = LimitedArray<Int>(3)
        XCTAssertTrue(array.append(1))
        XCTAssertTrue(array.append(2))
        XCTAssertTrue(array.append(3))
        XCTAssertEqual(array.count, 3)
      }

      XCTContext.runActivity(named: "Exceeding upper limit") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        array.append(2)
        array.append(3)
        XCTAssertFalse(array.append(4))
        XCTAssertEqual(array.count, 3)
        XCTAssertEqual(array.first, 1)
        XCTAssertEqual(array[1], 2)
        XCTAssertEqual(array.last, 3)
      }
    }
  }

  func testCount() {
    XCTContext.runActivity(named: "Count") { _ in
      XCTContext.runActivity(named: "Empty") { _ in
        let array = LimitedArray<Int>(3)
        XCTAssertTrue(array.isEmpty)
      }

      XCTContext.runActivity(named: "One") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        XCTAssertEqual(array.count, 1)
      }

      XCTContext.runActivity(named: "Two") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        array.append(2)
        XCTAssertEqual(array.count, 2)
      }

      XCTContext.runActivity(named: "Three") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        array.append(2)
        array.append(3)
        XCTAssertEqual(array.count, 3)
        array.append(4)
        XCTAssertEqual(array.count, 3)
      }
    }
  }

  func testRemove() {
    XCTContext.runActivity(named: "Replace") { _ in
      XCTContext.runActivity(named: "In range") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        array.append(2)
        array.append(3)
        array.remove(at: 2)
        XCTAssertEqual(array.count, 2)
      }

      XCTContext.runActivity(named: "Out of range") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        XCTAssertFalse(array.remove(at: 1))
        array.append(2)
        array.append(3)
        XCTAssertFalse(array.remove(at: 3))
        XCTAssertEqual(array.count, 3)
      }
    }
  }

  func testReplace() {
    XCTContext.runActivity(named: "Replace") { _ in
      XCTContext.runActivity(named: "In range") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        array.append(2)
        array.append(3)
        array.replace(4, at: 1)
        XCTAssertEqual(array[1], 4)
        XCTAssertEqual(array.count, 3)
      }

      XCTContext.runActivity(named: "Out of range") { _ in
        var array = LimitedArray<Int>(3)
        array.append(1)
        XCTAssertFalse(array.replace(1, at: 4))
        array.append(2)
        array.append(3)
        XCTAssertFalse(array.replace(4, at: 5))
        XCTAssertEqual(array.count, 3)
      }
    }
  }
}
