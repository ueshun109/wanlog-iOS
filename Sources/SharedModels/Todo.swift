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
  public var reminderDate: [Timestamp]?
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
    reminderDate: [Timestamp]? = nil,
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
    self.reminderDate = reminderDate
    self.repeatDate = repeatDate
  }
}

public extension Todo {
  typealias ConvinienceObject = (
    complete: Bool,
    dogId: String,
    expiredDate: Timestamp,
    notificationDate: [Timestamp],
    ownerId: String
  )

  static let combinationVaccine: (ConvinienceObject) -> Todo = { task in
    .init(
      content: "混合ワクチン接種",
      complete: task.complete,
      dogId: task.dogId,
      expiredDate: task.expiredDate,
      ownerId: task.ownerId,
      priority: .high
    )
  }

  static let filariasisDosing: (ConvinienceObject) -> Todo = { task in
    .init(
      content: "フィラリア症予防薬投与",
      complete: task.complete,
      dogId: task.dogId,
      expiredDate: task.expiredDate,
      ownerId: task.ownerId,
      priority: .high
    )
  }

  static let rabiesVaccine: (ConvinienceObject) -> Todo = { task in
    .init(
      content: "狂犬病ワクチン接種",
      complete: task.complete,
      dogId: task.dogId,
      expiredDate: task.expiredDate,
      ownerId: task.ownerId,
      priority: .high
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
  func nextTodos() -> [Todo] {
    let nextTodos: [Todo] = self.compactMap { todo in
      guard todo.complete, let repeatDate = todo.repeatDate else { return nil }
      let diff: TimeInterval = TimeInterval(repeatDate.seconds - todo.expiredDate.seconds)
      var new = todo
      new.complete = false
      new.expiredDate = repeatDate
      if let _repeatDate = RepeatDate(timeInterval: diff)?.date(new.expiredDate.dateValue()) {
        new.repeatDate = Timestamp(date: _repeatDate)
      } else {
        new.repeatDate = nil
      }
      return new
    }
    return nextTodos
  }
}
