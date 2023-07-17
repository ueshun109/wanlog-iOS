import SharedModels
import XCTest

class RabiesVaccineTest: XCTestCase {
  func testNextVaccinationDate() {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    // 2023/03/03 07:00:00
    let birthDate = Date(timeIntervalSince1970: 1677826800)

    XCTContext.runActivity(named: "currentDate is less than 91 days from birthDate") { _ in
      // 2023/06/01 07:00:00
      let currentDate = Date(timeIntervalSince1970: 1685602800)
      let vaccine = Dog.Preventions.RabiesVaccine()
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate,
        currentDate: currentDate
      )
      XCTAssertNil(nextVaccinationDate)
    }

    XCTContext.runActivity(named: "currentDate is 91 days or more from birthDate") { _ in
      // 2023/06/02 07:00:00
      let currentDate = Date(timeIntervalSince1970: 1685689200)
      let vaccine = Dog.Preventions.RabiesVaccine()
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate,
        currentDate: currentDate
      )
      XCTAssertEqual(nextVaccinationDate, currentDate)
    }

    XCTContext.runActivity(named: "have ever had a rabies vaccine") { _ in
      // 2023/06/02 07:00:00
      let lastVaccinationDate = Date(timeIntervalSince1970: 1685689200)
      // 2023/07/02 07:00:00
      let currentDate = Date(timeIntervalSince1970: 1688281200)
      // 2024/06/02 07:00:00
      let expectedDate = Date(timeIntervalSince1970: 1717311600)
      let vaccine = Dog.Preventions.RabiesVaccine(latestDate: lastVaccinationDate)
      let nextVaccinationDate = vaccine.nextVaccinationDate(
        calendar: calendar,
        birthDate: birthDate,
        currentDate: currentDate
      )
      XCTAssertEqual(nextVaccinationDate, expectedDate)
    }
  }
}
