import Foundation

public struct ReminderDate: Equatable, Hashable, Identifiable {
  public var id: String
  public var title: String

  private init(title: String) {
    self.id = title
    self.title = title
  }

  public static let atStart: ReminderDate = .init(title: "開始時")
  public static let tenMinutesAgo: ReminderDate = .init(title: "10分前")
  public static let oneHourAgo: ReminderDate = .init(title: "1時間前")
  public static let oneDayAgo: ReminderDate = .init(title: "1日前")
  public static let twoDaysAgo: ReminderDate = .init(title: "2日前")
  public static let threeDaysAgo: ReminderDate = .init(title: "3日前")

  public static let all: [ReminderDate] = [
    .atStart, .tenMinutesAgo, .oneHourAgo, .oneDayAgo, twoDaysAgo, threeDaysAgo
  ]

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
    default:
      fatalError("Unexpected case")
    }
  }
}
