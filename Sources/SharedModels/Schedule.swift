import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Schedule: Codable, Equatable, Identifiable {
  @DocumentID public var id: String?
  public var date: Timestamp
  public var content: String
  public var complete: Bool
  public var notificationDate: [Timestamp]
  public var ownerId: String
  public var dogId: String

  public init(
    id: String? = nil,
    date: Timestamp,
    content: String,
    complete: Bool,
    notificationDate: [Timestamp] = [],
    ownerId: String,
    dogId: String
  ) {
    self.id = id
    self.date = date
    self.content = content
    self.complete = complete
    self.notificationDate = notificationDate
    self.ownerId = ownerId
    self.dogId = dogId
  }

  public static let skeleton: [Schedule] =
  (0...2).map { i in
      .init(
        id: "\(i)",
        date: .init(date: Date()),
        content: String(repeating: " ", count: 10),
        complete: false,
        ownerId: "",
        dogId: ""
      )
  }
}
