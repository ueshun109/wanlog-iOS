import Core
import XCTest

final class QueueTest: XCTestCase {
  func testEnqueu() {
    var queue = Queue<Int>(3)
    queue.enqueue(1)
    queue.enqueue(2)
    queue.enqueue(3)
    queue.enqueue(4)
    XCTAssertEqual(queue[0], 2)
    XCTAssertEqual(queue[1], 3)
    XCTAssertEqual(queue[2], 4)
  }
}
