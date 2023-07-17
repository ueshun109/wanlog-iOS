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
      let vaccine = Dog.Preventions.CombinationVaccine()
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, firstDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .first") { _ in
      let vaccine = Dog.Preventions.CombinationVaccine(
        latestDate: firstDate,
        number: .first
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, secondDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .second") { _ in
      let vaccine = Dog.Preventions.CombinationVaccine(
        latestDate: secondDate,
        number: .second
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, thirdDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .third") { _ in
      let vaccine = Dog.Preventions.CombinationVaccine(
        latestDate: thirdDate,
        number: .third
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, fourthDate)
    }

    XCTContext.runActivity(named: "numberOfTimes is .moreThan") { _ in
      let vaccine = Dog.Preventions.CombinationVaccine(
        latestDate: fourthDate,
        number: .moreThan
      )
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate
      )!
      XCTAssertEqual(nextVaccinationDate, fifthDate)
    }
  }

  func testInitWithNumberOfTimes() {
    // 2023/03/03 07:00:00
    let birthDate = Date(timeIntervalSince1970: 1677826800)

    XCTContext.runActivity(named: "no time") { _ in
      // 2023/04/21 07:00:00
      let now = Date(timeIntervalSince1970: 1682060400)
      XCTAssertNil(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: now))
    }

    XCTContext.runActivity(named: "first time") { _ in
      // 2023/04/28 07:00:00
      let start = Date(timeIntervalSince1970: 1682665200)
      // 2023/05/19 07:00:00
      let end = Date(timeIntervalSince1970: 1684479600)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: start), .first)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: end), .first)
    }

    XCTContext.runActivity(named: "second time") { _ in
      // 2023/05/26 07:00:00
      let start = Date(timeIntervalSince1970: 1685084400)
      // 2023/06/23 06:59:59
      let end = Date(timeIntervalSince1970: 1687503599)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: start), .second)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: end), .second)
    }

    XCTContext.runActivity(named: "third time") { _ in
      // 2023/06/23 07:00:00
      let start = Date(timeIntervalSince1970: 1687503600)
      // 2023/07/21 06:59:59
      let end = Date(timeIntervalSince1970: 1689922799)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: start), .third)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: end), .third)
    }

    XCTContext.runActivity(named: "more than") { _ in
      // 2023/07/21 07:00:00
      let now = Date(timeIntervalSince1970: 1689922800)
      XCTAssertEqual(Dog.Preventions.CombinationVaccine.NumberOfTimes(birthDate: birthDate, now: now), .moreThan)
    }
  }
}
