import SharedModels
import XCTest

class RepeatDateTests: XCTestCase {
  private let calendar = Calendar.current

  func testInit() {
    XCTContext.runActivity(named: "day") { _ in
      let timeInterval: TimeInterval = 1677880800 - 1677794400
      guard let repeatDate: RepeatDate = .init(timeInterval: timeInterval) else {
        XCTFail()
        return
      }
      XCTAssertEqual(.everyDay, repeatDate)
    }

    XCTContext.runActivity(named: "week") { _ in
      let timeInterval: TimeInterval = 1678399200 - 1677794400
      guard let repeatDate: RepeatDate = .init(timeInterval: timeInterval) else {
        XCTFail()
        return
      }
      XCTAssertEqual(.everyWeek, repeatDate)
    }

    XCTContext.runActivity(named: "month when leap year") { _ in
      let timeInterval: TimeInterval = 1709210706 - 1706791506
      guard let repeatDate: RepeatDate = .init(timeInterval: timeInterval) else {
        XCTFail()
        return
      }
      XCTAssertEqual(.everyMonth, repeatDate)
    }

    XCTContext.runActivity(named: "month when not leap year") { _ in
      let timeInterval: TimeInterval = 1675169106 - 1672577106
      guard let repeatDate: RepeatDate = .init(timeInterval: timeInterval) else {
        XCTFail()
        return
      }
      XCTAssertEqual(.everyMonth, repeatDate)
    }

    XCTContext.runActivity(named: "month when leap year") { _ in
      let timeInterval: TimeInterval = 1735689600 - 1704067200
      guard let repeatDate: RepeatDate = .init(timeInterval: timeInterval) else {
        XCTFail()
        return
      }
      XCTAssertEqual(.everyYear, repeatDate)
    }

    XCTContext.runActivity(named: "month when not leap year") { _ in
      let timeInterval: TimeInterval = 1704067200 - 1672531200
      guard let repeatDate: RepeatDate = .init(timeInterval: timeInterval) else {
        XCTFail()
        return
      }
      XCTAssertEqual(.everyYear, repeatDate)
    }
  }

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
