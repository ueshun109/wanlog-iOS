import Foundation

extension Todo {
  public enum ReminderDate: String, Hashable, Identifiable, CaseIterable {
    case atStart = "開始時"
    case tenMinutesAgo = "10分前"
    case oneHourAgo = "1時間前"
    case oneDayAgo = "1日前"
    case twoDaysAgo = "2日前"
    case threeDaysAgo = "3日前"

    public init?(lhs: Date, rhs: Date) {
      let interval = lhs.timeIntervalSince(rhs)
      switch abs(interval) {
      case 0:
        self = .atStart
      case 60 * 10:
        self = .tenMinutesAgo
      case 60 * 60:
        self = .oneHourAgo
      case 60 * 60 * 24:
        self = .oneDayAgo
      case 60 * 60 * 24 * 2:
        self = .twoDaysAgo
      case 60 * 60 * 24 * 3:
        self = .threeDaysAgo
      default:
        return nil
      }
    }

    public var id: String { self.rawValue }

    public func date(_ date: Date, calendar: Calendar = .current) -> Date {
      switch self {
      case .atStart:
        return date
      case .tenMinutesAgo:
        return calendar.date(byAdding: .minute, value: -10, to: date)!
      case .oneHourAgo:
        return calendar.date(byAdding: .hour, value: -1, to: date)!
      case .oneDayAgo:
        return calendar.date(byAdding: .day, value: -1, to: date)!
      case .twoDaysAgo:
        return calendar.date(byAdding: .day, value: -2, to: date)!
      case .threeDaysAgo:
        return calendar.date(byAdding: .day, value: -3, to: date)!
      }
    }
  }
}
