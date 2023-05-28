import Foundation

/// Vaccine to prevent rabies
public struct RabiesVaccine {
  /// Last vaccination date
  public var lastVaccinationDate: Date?

  /// Create new instance
  /// - Parameter lastVaccinationDate: Last vaccination date. Nil if never vaccinated.
  public init(lastVaccinationDate: Date? = nil) {
    self.lastVaccinationDate = lastVaccinationDate
  }

  /// Determine the next scheduled vaccination date.
  /// - Parameters:
  ///   - calendar: `Calendar`
  ///   - birthDate: dog birth date
  /// - Returns: Scheduled date of next vaccination.
  public func nextVaccinationDate(
    calendar: Calendar = .current,
    birthDate: Date,
    currentDate: Date = .now
  ) -> Date? {
    guard let lastVaccinationDate else {
      let diff = calendar.dateComponents([.day], from: birthDate, to: currentDate)
      if let days = diff.day, days >= 91 {
        return currentDate
      } else {
        return nil
      }
    }

    let nextYear = calendar.date(byAdding: .year, value: 1, to: lastVaccinationDate)
    return nextYear
  }
}
