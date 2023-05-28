import SharedModels
import XCTest

class CombinationVaccineTest: XCTestCase {
  func testNextVaccinationDate() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    // 2023/03/03 07:00:00
    let birthDate = Date(timeIntervalSince1970: 1677826800)
    // 2023/04/28 07:00:00
    let firstDate = Date(timeIntervalSince1970: 1682665200)
    // 2023/05/26 07:00:00
    let secondDate = Date(timeIntervalSince1970: 1685084400)
    // 2023/06/23 07:00:00
    let thirdDate = Date(timeIntervalSince1970: 1687503600)
    // 2024/06/23 07:00:00
    let fourthDate = Date(timeIntervalSince1970: 1719126000)
    // 2025/06/23 07:00:00
    let fifthDate = Date(timeIntervalSince1970: 1750662000)

    XCTContext.runActivity(named: "lastVaccinationDate and numberOfTimes are nil") { _ in
      let vaccine = CombinationVaccine()
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, firstDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .first") { _ in
      let vaccine = CombinationVaccine(
        lastVaccinationDate: firstDate,
        numberOfCombinationVaccinations: .first
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, secondDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .second") { _ in
      let vaccine = CombinationVaccine(
        lastVaccinationDate: secondDate,
        numberOfCombinationVaccinations: .second
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, thirdDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .third") { _ in
      let vaccine = CombinationVaccine(
        lastVaccinationDate: thirdDate,
        numberOfCombinationVaccinations: .third
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, fourthDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .moreThan") { _ in
      let vaccine = CombinationVaccine(
        lastVaccinationDate: fourthDate,
        numberOfCombinationVaccinations: .moreThan
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, fifthDate)
    }
  }

  func testInitWithNumberOfTimes() {
    XCTContext.runActivity(named: "no time") { _ in
      var components = DateComponents()
      components.weekOfYear = 7
      XCTAssertNil(CombinationVaccine.NumberOfTimes(weekOfAge: components))
    }

    XCTContext.runActivity(named: "first time") { _ in
      var components = DateComponents()
      components.weekOfYear = 8
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .first)
      components.weekOfYear = 11
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .first)
    }

    XCTContext.runActivity(named: "second time") { _ in
      var components = DateComponents()
      components.weekOfYear = 12
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .second)
      components.weekOfYear = 15
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .second)
    }

    XCTContext.runActivity(named: "third time") { _ in
      var components = DateComponents()
      components.weekOfYear = 16
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .third)
      components.weekOfYear = 19
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .third)
    }

    XCTContext.runActivity(named: "more than") { _ in
      var components = DateComponents()
      components.weekOfYear = 20
      XCTAssertEqual(CombinationVaccine.NumberOfTimes(weekOfAge: components), .moreThan)
    }
  }
}
