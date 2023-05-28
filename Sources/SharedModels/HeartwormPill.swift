import Foundation

/// Medicines to prevent heartworm disease
public struct HeartwormPill {
  /// The last time you gave your dog medicine
  public var lastGivenDate: Date?

  /// Create new instance
  /// - Parameter lastGivenDate: The last time you gave your dog medicine
  public init(lastGivenDate: Date? = nil) {
    self.lastGivenDate = lastGivenDate
  }

  /// Determine the next scheduled dosing date.
  /// - Parameters:
  ///   - calendar: `Calendar`
  ///   - currentDate: current date
  /// - Returns:  Scheduled date of next dosing.
  public func nextDosingDate(
    calendar: Calendar = .current,
    currentDate: Date = .now
  ) -> Date {
    let currentMonth = calendar.component(.month, from: currentDate)
    let april = 4
    let november = 11
    let december = 12
    guard let lastGivenDate else {
      if april...december ~= currentMonth {
        let rightNow: Date = currentDate
        return rightNow
      } else {
        let nextApril = nextApril(calendar: calendar, date: currentDate) ?? currentDate
        return nextApril
      }
    }

    let lastGivenDateMonth = calendar.component(.month, from: lastGivenDate)
    if april...november ~= lastGivenDateMonth {
      let nextMonth = calendar.date(byAdding: .month, value: 1, to: lastGivenDate)
      return nextMonth ?? currentDate
    } else {
      let nextApril = nextApril(calendar: calendar, date: currentDate) ?? currentDate
      return nextApril
    }
  }

  private func nextApril(
    calendar: Calendar,
    date: Date
  ) -> Date? {
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let nextMayYear = month >= 4 ? year + 1 : year

    var dateComponents = DateComponents()
    dateComponents.year = nextMayYear
    dateComponents.month = 4
    dateComponents.day = 1
    let nextMay = calendar.date(from: dateComponents)
    return nextMay
  }
}
