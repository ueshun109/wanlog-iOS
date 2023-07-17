import FirebaseFirestore
import SharedModels
import XCTest

class TodoTest: XCTestCase {
  func testNextTodos() {
    XCTContext.runActivity(named: "次の期限日が現在よりも古い") { _ in
      XCTContext.runActivity(named: "期限が切れてから24時間以内に完了") { _ in
        let completeTodo: [Todo] = [Self.fake]
        /**
         expiredDate: 2023-07-03 09:00
         repeatDate: 2023-07-04 09:00
         reminderDates: 2023-07-03 08:00 (Not contain `2023-07-02 09:00`)
         */
        let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .hour, 19))
        XCTAssertFalse(nextTodo.first!.complete)
        XCTAssertEqual(Self.date(byAdding: .day, 1), nextTodo.first!.expiredDate.dateValue())
        XCTAssertEqual(Self.date(byAdding: .day, 2), nextTodo.first!.repeatDate!.dateValue())
        XCTAssertEqual(Self.date(byAdding: .hour, 23), nextTodo.first!.reminderDates!.first!.dateValue())
        XCTAssertTrue(nextTodo.first!.reminderDates!.count == 1)
      }

      XCTContext.runActivity(named: "期限が切れてからちょうど1日後に完了") { _ in
        let completeTodo: [Todo] = [Self.fake]
        /**
         expiredDate: 2023-07-04 09:00
         repeatDate: 2023-07-05 09:00
         reminderDates: 2023-07-04 08:00 (Not contain `2023-07-03 09:00`)
         */
        let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .day, 1))
        XCTAssertFalse(nextTodo.first!.complete)
        XCTAssertEqual(Self.date(byAdding: .day, 2), nextTodo.first!.expiredDate.dateValue())
        XCTAssertEqual(Self.date(byAdding: .day, 3), nextTodo.first!.repeatDate!.dateValue())
        XCTAssertEqual(Self.date(byAdding: .hour, 47), nextTodo.first!.reminderDates!.first!.dateValue())
        XCTAssertTrue(nextTodo.first!.reminderDates!.count == 1)
      }

      XCTContext.runActivity(named: "期限が切れてから24~48時間以内に完了") { _ in
        let completeTodo: [Todo] = [Self.fake]
        /**
         expiredDate: 2023-07-04 09:00
         repeatDate: 2023-07-05 09:00
         reminderDates: No Item
         */
        let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .hour, 47))
        XCTAssertFalse(nextTodo.first!.complete)
        XCTAssertEqual(Self.date(byAdding: .day, 2), nextTodo.first!.expiredDate.dateValue())
        XCTAssertEqual(Self.date(byAdding: .day, 3), nextTodo.first!.repeatDate!.dateValue())
        XCTAssertTrue(nextTodo.first!.reminderDates!.isEmpty)
      }

      XCTContext.runActivity(named: "期限が切れてからちょうど2日後に完了") { _ in
        let completeTodo: [Todo] = [Self.fake]
        /**
         expiredDate: 2023-07-05 09:00
         repeatDate: 2023-07-06 09:00
         reminderDates: 2023-07-06 08:00
         */
        let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .day, 2))
        XCTAssertFalse(nextTodo.first!.complete)
        XCTAssertEqual(Self.date(byAdding: .day, 3), nextTodo.first!.expiredDate.dateValue())
        XCTAssertEqual(Self.date(byAdding: .day, 4), nextTodo.first!.repeatDate!.dateValue())
        XCTAssertEqual(Self.date(byAdding: .hour, 71), nextTodo.first!.reminderDates!.first!.dateValue())
        XCTAssertTrue(nextTodo.first!.reminderDates!.count == 1)
      }

      XCTContext.runActivity(named: "期限が切れてから48時間以上経過後に完了") { _ in
        let completeTodo: [Todo] = [Self.fake]
        /**
         expiredDate: 2023-07-09 09:00
         repeatDate: 2023-07-10 09:00
         reminderDates: 2023-07-09 08:00
         */
        let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .hour, 166))
        XCTAssertFalse(nextTodo.first!.complete)
        XCTAssertEqual(Self.date(byAdding: .day, 7), nextTodo.first!.expiredDate.dateValue())
        XCTAssertEqual(Self.date(byAdding: .day, 8), nextTodo.first!.repeatDate!.dateValue())
        XCTAssertEqual(Self.date(byAdding: .hour, 167), nextTodo.first!.reminderDates!.first!.dateValue())
        XCTAssertTrue(nextTodo.first!.reminderDates!.count == 1)
      }

      XCTContext.runActivity(named: "期限が切れてからちょうど1週間後に完了") { _ in
        let completeTodo: [Todo] = [Self.fake]
        /**
         expiredDate: 2023-07-10 09:00
         repeatDate: 2023-07-11 09:00
         reminderDates: 2023-07-10 08:00
         */
        let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .hour, 168))
        XCTAssertFalse(nextTodo.first!.complete)
        XCTAssertEqual(Self.date(byAdding: .day, 8), nextTodo.first!.expiredDate.dateValue())
        XCTAssertEqual(Self.date(byAdding: .day, 9), nextTodo.first!.repeatDate!.dateValue())
        XCTAssertEqual(Self.date(byAdding: .hour, 191), nextTodo.first!.reminderDates!.first!.dateValue())
        XCTAssertTrue(nextTodo.first!.reminderDates!.count == 1)
      }
    }

    XCTContext.runActivity(named: "次の期限日が現在よりも新しい") { _ in
      let completeTodo: [Todo] = [Self.fake]
      /**
       expiredDate: 2023-07-03  09:00
       repeatDate: 2023-07-04 09:00
       reminderDates: 2023-07-03 08:00 , 2023-07-02 09:00
       */
      let nextTodo = completeTodo.nextTodos(now: Self.date(byAdding: .hour, -7))
      XCTAssertFalse(nextTodo.first!.complete)
      XCTAssertEqual(Self.date(byAdding: .day, 1), nextTodo.first!.expiredDate.dateValue())
      XCTAssertEqual(Self.date(byAdding: .day, 2), nextTodo.first!.repeatDate!.dateValue())
      XCTAssertEqual(Self.date(byAdding: .hour, 23), nextTodo.first!.reminderDates!.first!.dateValue())
      XCTAssertEqual(Self.date(byAdding: .hour, 0), nextTodo.first!.reminderDates!.last!.dateValue())
      XCTAssertTrue(nextTodo.first!.reminderDates!.count == 2)
    }
  }
}

extension TodoTest {
  static func date(byAdding component: Calendar.Component, _ i: Int) -> Date {
    // 2023-07-02 09:00
    let baseDate = Date(timeIntervalSince1970: 1688288400)
    return Calendar.current.date(byAdding: component, value: i, to: baseDate)!
  }

  static let fake: Todo = .init(
    content: "",
    complete: true,
    dogId: "1",
    expiredDate: .init(date: date(byAdding: .day, 0)),
    ownerId: "1",
    priority: .medium,
    reminderDates: [
      .init(date: date(byAdding: .hour, -1)),
      .init(date: date(byAdding: .day, -1)),
    ],
    repeatDate: .init(date: date(byAdding: .hour, 24))
  )

//  func completedTodos() -> [Todo] {
//    (0..<3).map { i in
//        .init(
//          content: "Test\(i)",
//          complete: true,
//          dogId: "dog",
//          expiredDate: .init(date: date(0)),
//          ownerId: "owner",
//          priority: .medium,
//          repeatDate: .init(date: date(i+1))
//        )
//    }
//  }
}
