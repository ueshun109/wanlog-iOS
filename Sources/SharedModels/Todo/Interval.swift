import Foundation

extension Todo {
  public enum Interval: String, Hashable, Identifiable, CaseIterable {
    case everyDay = "毎日"
    case everyWeek = "毎週"
    case everyMonth = "毎月"
    case everyYear = "毎年"

    public var id: String { rawValue }

    public init?(timeInterval: TimeInterval) {
      let day: TimeInterval = 60 * 60 * 24
      let week: TimeInterval = day * 7
      let monthWhenLeapYear: TimeInterval = 60 * 60 * 24 * 28
      let monthWhenNotLeapYear: TimeInterval = 60 * 60 * 24 * 31
      let leapYear: TimeInterval = 60 * 60 * 24 * 365
      let notLeapYear: TimeInterval = 60 * 60 * 24 * 366

      switch timeInterval {
      case day:
        self = .everyDay
      case week:
        self = .everyWeek
      case monthWhenLeapYear...monthWhenNotLeapYear:
        self = .everyMonth
      case leapYear...notLeapYear:
        self = .everyYear
      default:
        return nil
      }
    }

    /// Returns the next date according to the type.
    /// - Parameters:
    ///   - date: `Date`
    ///   - calendar: `Calendar`
    /// - Returns: The next date according to the type.
    public func date(_ date: Date, calendar: Calendar = .current) -> Date {
      switch self {
      case .everyDay:
        return calendar.date(byAdding: .day, value: 1, to: date)!
      case .everyWeek:
        return calendar.date(byAdding: .day, value: 7, to: date)!
      case .everyMonth:
        return calendar.date(byAdding: .month, value: 1, to: date)!
      case .everyYear:
        return calendar.date(byAdding: .year, value: 1, to: date)!
      }
    }
  }
}
