import SharedModels
import XCTest

class ReminderDateTests: XCTestCase {
  private let calendar = Calendar.current

  func testAtStart() {
    let now = Date()
    let date = ReminderDate.atStart.date(now)
    XCTAssertEqual(now, date)
  }

  func testTenMinutesAgo() {
    let now = Date()
    let date = ReminderDate.tenMinutesAgo.date(now)
    let expectedDate = calendar.date(byAdding: .minute, value: -10, to: now)!
    XCTAssertEqual(date, expectedDate)
  }

  func testOneHourAgo() {
    let now = Date()
    let date = ReminderDate.oneHourAgo.date(now)
    let expectedDate = calendar.date(byAdding: .hour, value: -1, to: now)!
    XCTAssertEqual(date, expectedDate)
  }

  func testOneDayAgo() {
    let now = Date()
    let date = ReminderDate.oneDayAgo.date(now)
    let expectedDate = calendar.date(byAdding: .day, value: -1, to: now)!
    XCTAssertEqual(date, expectedDate)
  }

  func testTwoDaysAgo() {
    let now = Date()
    let date = ReminderDate.twoDaysAgo.date(now)
    let expectedDate = calendar.date(byAdding: .day, value: -2, to: now)!
    XCTAssertEqual(date, expectedDate)
  }

  func testThreeDaysAgo() {
    let now = Date()
    let date = ReminderDate.threeDaysAgo.date(now)
    let expectedDate = calendar.date(byAdding: .day, value: -3, to: now)!
    XCTAssertEqual(date, expectedDate)
  }
}

