import Foundation

/// Reminde notificaton date
public enum NotificationDate {
  case atStart
  case tenMinutesAgo
  case oneHourAgo

  public init?(lhs: Date, rhs: Date) {
    let interval = lhs.timeIntervalSince(rhs)
    switch interval {
    case 0:
      self = .atStart
    case 60 * 10:
      self = .tenMinutesAgo
    case 60 * 60:
      self = .oneHourAgo
    default:
      return nil
    }
  }

  public var title: String {
    switch self {
    case .atStart:
      return "開始時"
    case .tenMinutesAgo:
      return "10分前"
    case .oneHourAgo:
      return "1時間前"
    }
  }

  /// Return notification date from specified date.
  /// - Parameter date: `Date`
  /// - Returns: Notification date
  public func date(from date: Date) -> Date {
    switch self {
    case .atStart:
      return date
    case .tenMinutesAgo:
      return Date(timeInterval: -(60 * 10), since: date)
    case .oneHourAgo:
      return Date(timeInterval: -(60 * 60), since: date)
    }
  }
}
