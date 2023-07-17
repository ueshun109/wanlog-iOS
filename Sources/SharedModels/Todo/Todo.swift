import Core
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Todo: Codable, Equatable, Identifiable {
  /// Identifier
  @DocumentID public var id: String?
  /// Content
  public var content: String
  /// Whether the appointment is completed
  public var complete: Bool
  /// Which dog is this task for
  public var dogId: String
  /// Expired date
  public var expiredDate: Timestamp
  /// Supplementary matter
  public var memo: String?
  /// Dog owner identifier
  public var ownerId: String
  /// Priority
  public var priority: Priority
  /// Date for reminder
  public var reminderDates: [Timestamp]?
  /// Repeat date
  public var repeatDate: Timestamp?

  public init(
    id: String? = nil,
    content: String,
    complete: Bool,
    dogId: String,
    expiredDate: Timestamp,
    memo: String? = nil,
    ownerId: String,
    priority: Priority,
    reminderDates: [Timestamp]? = nil,
    repeatDate: Timestamp? = nil
  ) {
    self.id = id
    self.content = content
    self.complete = complete
    self.dogId = dogId
    self.expiredDate = expiredDate
    self.memo = memo
    self.ownerId = ownerId
    self.priority = priority
    self.reminderDates = reminderDates
    self.repeatDate = repeatDate
  }
}

// MARK: - Static instance

public extension Todo {
  typealias IdAndExpiredDate = (
    dogId: String,
    ownerId: String,
    expiredDate: Date
  )

  static let combinationVaccination: (IdAndExpiredDate) -> Todo = { object in
    let repeatDateType: Interval = .everyYear
    let repeatDate: Timestamp = .init(date: repeatDateType.date(object.expiredDate))
    let reminderDateTypes: Set<ReminderDate> = [.atStart, .oneDayAgo]
    let reminderDate: [Timestamp] = reminderDateTypes
      .map {
        let date = $0.date(object.expiredDate)
        return .init(date: date)
      }
    return .init(
      content: .localized(.combinationVaccination),
      complete: false,
      dogId: object.dogId,
      expiredDate: .init(date: object.expiredDate),
      ownerId: object.ownerId,
      priority: .high,
      reminderDates: reminderDate,
      repeatDate: repeatDate
    )
  }

  static let giveHeartwormPill: (IdAndExpiredDate) -> Todo = { object in
    let repeatDateType: Interval = .everyMonth
    let repeatDate: Timestamp = .init(date: repeatDateType.date(object.expiredDate))
    let reminderDateTypes: Set<ReminderDate> = [.atStart, .oneDayAgo]
    let reminderDate: [Timestamp] = reminderDateTypes
      .map {
        let date = $0.date(object.expiredDate)
        return .init(date: date)
      }
    return .init(
      content: .localized(.giveHeartwormPill),
      complete: false,
      dogId: object.dogId,
      expiredDate: .init(date: object.expiredDate),
      ownerId: object.ownerId,
      priority: .high,
      reminderDates: reminderDate,
      repeatDate: repeatDate
    )
  }

  static let rabiesVaccination: (IdAndExpiredDate) -> Todo = { object in
    let repeatDateType: Interval = .everyYear
    let repeatDate: Timestamp = .init(date: repeatDateType.date(object.expiredDate))
    let reminderDateTypes: Set<ReminderDate> = [.atStart, .oneDayAgo]
    let reminderDates: [Timestamp] = reminderDateTypes
      .map {
        let date = $0.date(object.expiredDate)
        return .init(date: date)
      }
    return .init(
      content: .localized(.rabiesVaccination),
      complete: false,
      dogId: object.dogId,
      expiredDate: .init(date: object.expiredDate),
      ownerId: object.ownerId,
      priority: .high,
      reminderDates: reminderDates,
      repeatDate: repeatDate
    )
  }

  static let fakes: [Todo] = [
    .init(
      content: "Task 1",
      complete: false,
      dogId: "",
      expiredDate: .init(date: Date()),
      ownerId: "",
      priority: .medium
    ),
    .init(
      content: "Task 2",
      complete: false,
      dogId: "",
      expiredDate: .init(date: Date()),
      ownerId: "",
      priority: .medium
    ),
  ]
}

// MARK: - Helper method for expired

public extension Todo {
  /// Whether the expiration date has expired or not.
  /// - Parameter date: Date to be compared.
  /// - Returns: Returns true if expired.
  func expired(date: Date = .now) -> Bool {
    let timeInterval: Int64 = expiredDate.seconds - Int64(date.timeIntervalSince1970)
    return timeInterval < 0
  }

  /// Whether it should be brought to our attention.
  /// - Parameter date: Date.
  /// - Returns: Returns true if attention is given.
  func shouldAttention(date: Date = .now) -> Bool {
    let timeInterval: Int64 = expiredDate.seconds - Int64(date.timeIntervalSince1970)
    let within24Hours = timeInterval > 0 && timeInterval <= 60 * 60 * 24
    return priority == .high && within24Hours
  }

  /// Whether the deadline is within 24 hours.
  /// - Parameter date: Date to be compared.
  /// - Returns: Returns true if deadline is within 24 hours.
  func within24Hours(date: Date = .now) -> Bool {
    let timeInterval: Int64 = expiredDate.seconds - Int64(date.timeIntervalSince1970)
    return timeInterval > 0 && timeInterval <= 60 * 60 * 24
  }
}

 // MARK: - Helper methods for array

public extension [Todo] {
  mutating func removedCompleted() -> [Todo] {
    let removed = self.filter { $0.complete }
    self = self.filter { !$0.complete }
    return removed
  }

  mutating func removedWithin24Hours(_ now: Date = .now) -> [Todo] {
    let removed = self.filter { $0.within24Hours(date: now) }
    self = self.filter { !$0.within24Hours(date: now) }
    return removed
  }

  mutating func removedExpired(_ now: Date = .now) -> [Todo] {
    let removed = self.filter { $0.expired(date: now) }
    self = self.filter { !$0.expired(date: now) }
    return removed
  }

  /// Create a new todo by updating the due date and repeat date of the completed todo.
  /// - Returns: New todo list.
  func nextTodos(now: Date = .now) -> [Todo] {
    // 次のタスクが今の日付よりも古い場合、今の日付を基準としてrepeatDateに期限のタスクを作る
    self.compactMap { todo in
      guard
        todo.complete,
        let tentativeNextExpiredDate = todo.repeatDate,
        let interval = Todo.Interval(timeInterval: .init(tentativeNextExpiredDate.seconds - todo.expiredDate.seconds))
      else { return nil }

      let nextExpiredDate: Timestamp = {
        var nextDate = tentativeNextExpiredDate.dateValue()
        while nextDate <= now { nextDate = interval.date(nextDate) }
        return .init(date: nextDate)
      }()

      let nextReminderDates: [Timestamp]? = {
        return todo.reminderDates?.compactMap { timestamp in
          guard let reminder = Todo.ReminderDate(
            lhs: todo.expiredDate.dateValue(),
            rhs: timestamp.dateValue()
          ) else { return nil }
          return Timestamp(date: reminder.date(nextExpiredDate.dateValue()))
        }
        .filter { now < $0.dateValue() } // 既にリマインド日が過ぎている場合は、保存しない。
      }()

      let nextRepeatDate: Timestamp = .init(date: interval.date(nextExpiredDate.dateValue()))

      var new = todo
      new.complete = false
      new.expiredDate = nextExpiredDate
      new.repeatDate = nextRepeatDate
      new.reminderDates = nextReminderDates
      return new
    }
  }
}
