import FirebaseFirestore
import FirebaseFirestoreSwift

public protocol Todo: Codable, Equatable, Identifiable {
  /// Id
  var id: String? { get }
  /// Content
  var content: String { get }
  /// Whether the appointment is completed
  var complete: Bool { get }
  /// Which dog is this task for
  var dogId: String { get }
  /// Expired date
  var expiredDate: Timestamp { get }
  /// Supplementary matter
  var memo: String? { get }
  /// Dog owner id.
  var ownerId: String { get }
  /// Priority
  var priority: Priority { get }
  /// Date for reminder
  var reminderDate: [Timestamp]? { get }
}

public extension Todo {
  var memo: String? { nil }
  var reminderDate: [Timestamp]? { nil }
}

public typealias ConvinienceTask = (
  complete: Bool,
  dogId: String,
  expiredDate: Timestamp,
  notificationDate: [Timestamp],
  ownerId: String
)

public struct RequiredTask: Todo {
  @DocumentID public var id: String?
  public var content: String
  public var complete: Bool
  public var dogId: String
  public var expiredDate: Timestamp
  public var ownerId: String
  public var priority: Priority

  public init(
    content: String,
    complete: Bool,
    dogId: String,
    expiredDate: Timestamp,
    ownerId: String,
    priority: Priority
  ) {
    self.content = content
    self.complete = complete
    self.dogId = dogId
    self.expiredDate = expiredDate
    self.ownerId = ownerId
    self.priority = priority
  }

  public static let combinationVaccine: (ConvinienceTask) -> RequiredTask = { task in
    .init(
      content: "混合ワクチン接種",
      complete: task.complete,
      dogId: task.dogId,
      expiredDate: task.expiredDate,
      ownerId: task.ownerId,
      priority: .high
    )
  }

  public static let filariasisDosing: (ConvinienceTask) -> RequiredTask = { task in
    .init(
      content: "フィラリア症予防薬投与",
      complete: task.complete,
      dogId: task.dogId,
      expiredDate: task.expiredDate,
      ownerId: task.ownerId,
      priority: .high
    )
  }

  public static let rabiesVaccine: (ConvinienceTask) -> RequiredTask = { task in
    .init(
      content: "狂犬病ワクチン接種",
      complete: task.complete,
      dogId: task.dogId,
      expiredDate: task.expiredDate,
      ownerId: task.ownerId,
      priority: .high
    )
  }
}

public struct NormalTask: Todo {
  @DocumentID public var id: String?
  public var content: String
  public var complete: Bool
  public var dogId: String
  public var expiredDate: Timestamp
  public var memo: String?
  public var ownerId: String
  public var priority: Priority
  public var reminderDate: [Timestamp]?

  public init(
    id: String? = nil,
    content: String,
    complete: Bool,
    dogId: String,
    expiredDate: Timestamp,
    memo: String? = nil,
    ownerId: String,
    priority: Priority,
    reminderDate: [Timestamp]? = nil
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
  }

  public static let fakes: [NormalTask] = [
    .init(
      content: "Normal Task 1",
      complete: false,
      dogId: "",
      expiredDate: .init(date: Date()),
      ownerId: "",
      priority: .high
    ),
    .init(
      content: "Normal Task 2",
      complete: false,
      dogId: "",
      expiredDate: .init(date: Date()),
      ownerId: "",
      priority: .medium
    ),
  ]
}
