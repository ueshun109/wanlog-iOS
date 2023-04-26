import Foundation

public enum RepeatDate: String, Hashable, Identifiable, CaseIterable {
  case everyDay = "毎日"
  case everyWeek = "毎週"
  case everyMonth = "毎月"
  case everyYear = "毎年"

  public var id: String { rawValue }

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
