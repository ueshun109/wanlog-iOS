import FirebaseFirestore
import SharedModels
import XCTest

class TodoTest: XCTestCase {
  func testNextTodos() {
    let completedTodos = completedTodos()
    let nextTodos = completedTodos.nextTodos()
    for (index, value) in zip(completedTodos.indices, completedTodos) {
      let updatedExpireDate = nextTodos[index].expiredDate == value.repeatDate!
      let updatedRepeatDate = nextTodos[index].repeatDate == Timestamp(date: date(index + 2))
      XCTAssertFalse(nextTodos[index].complete)
      XCTAssertTrue(updatedExpireDate)
      XCTAssertTrue(updatedRepeatDate)
    }
  }
}

extension TodoTest {
  func date(_ i: Int) -> Date {
    let baseDate = Date(timeIntervalSince1970: 1677880800)
    return Calendar.current.date(byAdding: .day, value: 1 + i, to: baseDate)!
  }

  func completedTodos() -> [Todo] {
    (0..<3).map { i in
        .init(
          content: "Test\(i)",
          complete: true,
          dogId: "dog\(i)",
          expiredDate: .init(date: date(i)),
          ownerId: "owner\(i)",
          priority: .medium,
          repeatDate: .init(date: date(i+1))
        )
    }
  }
}
