import SharedModels
import XCTest

class RepeatDateTests: XCTestCase {
  private let calendar = Calendar.current

  func testEveryDay() {
    let start = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1677880800)
    let repeatDate: RepeatDate = .everyDay
    XCTAssertEqual(expected, repeatDate.date(start))
  }

  func testEveryWeek() {
    let start = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1678399200)
    let repeatDate: RepeatDate = .everyWeek
    XCTAssertEqual(expected, repeatDate.date(start))
  }

  func testEveryMonth() {
    let start = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1680472800)
    let repeatDate: RepeatDate = .everyMonth
    XCTAssertEqual(expected, repeatDate.date(start))
  }

  func testEveryYear() {
    let start = Date(timeIntervalSince1970: 1677794400)
    let expected = Date(timeIntervalSince1970: 1709416800)
    let repeatDate: RepeatDate = .everyYear
    XCTAssertEqual(expected, repeatDate.date(start))
  }
}
