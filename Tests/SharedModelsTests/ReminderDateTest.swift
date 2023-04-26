import SharedModels
import XCTest

class ReminderDateTests: XCTestCase {
  private let calendar = Calendar.current

  func testAtStart() {
    let now = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677794400)
    let reminderDate: ReminderDate = .atStart
    XCTAssertEqual(expected, reminderDate.date(now))
  }

  func testTenMinutesAgo() {
    let now = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677793800)
    let reminderDate: ReminderDate = .tenMinutesAgo
    XCTAssertEqual(expected, reminderDate.date(now))
  }

  func testOneHourAgo() {
    let now = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677790800)
    let reminderDate: ReminderDate = .oneHourAgo
    XCTAssertEqual(expected, reminderDate.date(now))
  }

  func testOneDayAgo() {
    let now = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677708000)
    let reminderDate: ReminderDate = .oneDayAgo
    XCTAssertEqual(expected, reminderDate.date(now))
  }

  func testTwoDaysAgo() {
    let now = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677621600)
    let reminderDate: ReminderDate = .twoDaysAgo
    XCTAssertEqual(expected, reminderDate.date(now))
  }

  func testThreeDaysAgo() {
    let now = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677535200)
    let reminderDate: ReminderDate = .threeDaysAgo
    XCTAssertEqual(expected, reminderDate.date(now))
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

