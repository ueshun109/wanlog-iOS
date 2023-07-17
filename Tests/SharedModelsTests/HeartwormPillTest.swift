import SharedModels
import XCTest

class HeartwormPillTest: XCTestCase {
  func testNextDosingDate() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    // 2023/01/03 07:00:00
    let january = Date(timeIntervalSince1970: 1672729200)
    // 2023/03/03 07:00:00
    let march = Date(timeIntervalSince1970: 1677826800)
    // 2023/04/03 07:00:00
    let april = Date(timeIntervalSince1970: 1680505200)
    // 2023/05/03 07:00:00
    let may = Date(timeIntervalSince1970: 1683097200)
    // 2023/11/03 07:00:00
    let november = Date(timeIntervalSince1970: 1698994800)
    // 2023/12/03 07:00:00
    let december = Date(timeIntervalSince1970: 1701586800)

    XCTContext.runActivity(named: "No given") { _ in
      XCTContext.runActivity(named: "Now is january") { _ in
        // 2023/04/01 00:00:00
        let expectedDate = Date(timeIntervalSince1970: 1680307200)
        let heartwormPill = Dog.Preventions.HeartwormPill()
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: january)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }

      XCTContext.runActivity(named: "Now is may") { _ in
        // 2023/04/01 00:00:00
        let expectedDate = Date(timeIntervalSince1970: 1680307200)
        let heartwormPill = Dog.Preventions.HeartwormPill()
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: march)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }

      XCTContext.runActivity(named: "Now is march") { _ in
        let expectedDate = april
        let heartwormPill = Dog.Preventions.HeartwormPill()
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: april)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }
    }

    XCTContext.runActivity(named: "Given") { _ in
      XCTContext.runActivity(named: "LastGivenDate is march") { _ in
        // 2023/05/01 00:00:00
        let expectedDate = Date(timeIntervalSince1970: 1680307200)
        let heartwormPill = Dog.Preventions.HeartwormPill(latestDate: march)
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: march)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }

      XCTContext.runActivity(named: "LastGivenDate is may") { _ in
        // 2023/06/01 07:00:00
        let expectedDate = Date(timeIntervalSince1970: 1685775600)
        let heartwormPill = Dog.Preventions.HeartwormPill(latestDate: may)
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: may)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }

      XCTContext.runActivity(named: "LastGivenDate is november") { _ in
        let expectedDate = december
        let heartwormPill = Dog.Preventions.HeartwormPill(latestDate: november)
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: november)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }

      XCTContext.runActivity(named: "LastGivenDate is december") { _ in
        // 2024/04/01 00:00:00
        let expectedDate = Date(timeIntervalSince1970: 1711929600)
        let heartwormPill = Dog.Preventions.HeartwormPill(latestDate: december)
        let nextDosingDate = heartwormPill.nextDosingDate(calendar: calendar, currentDate: december)
        XCTAssertEqual(nextDosingDate, expectedDate)
      }
    }
  }
}
