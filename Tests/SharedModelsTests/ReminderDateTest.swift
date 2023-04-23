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

  func testInit() {
    let start = Date(timeIntervalSince1970: 1677794400)
    let tenMinutesAgo = Date(timeIntervalSince1970: 1677795000)
    let oneHourAgo = Date(timeIntervalSince1970: 1677798000)
    let oneDayAgo = Date(timeIntervalSince1970: 1677880800)
    let twoDaysAgo = Date(timeIntervalSince1970: 1677967200)
    let threeDaysAgo = Date(timeIntervalSince1970: 1678053600)
    let invalid = Date(timeIntervalSince1970: 1645426800)

    XCTAssertEqual(ReminderDate(lhs: start, rhs: start), .atStart)
    XCTAssertEqual(ReminderDate(lhs: start, rhs: tenMinutesAgo), .tenMinutesAgo)
    XCTAssertEqual(ReminderDate(lhs: start, rhs: oneHourAgo), .oneHourAgo)
    XCTAssertEqual(ReminderDate(lhs: start, rhs: oneDayAgo), .oneDayAgo)
    XCTAssertEqual(ReminderDate(lhs: start, rhs: twoDaysAgo), .twoDaysAgo)
    XCTAssertEqual(ReminderDate(lhs: start, rhs: threeDaysAgo), .threeDaysAgo)
    XCTAssertNil(ReminderDate(lhs: start, rhs: invalid))
  }
}

