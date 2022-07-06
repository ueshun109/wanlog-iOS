import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Schedule: Codable, Equatable, Identifiable {
  @DocumentID public var id: String?
  public var date: Timestamp
  public var content: String
  public var complete: Bool
  public var ownerId: String

  public init(
    id: String? = nil,
    date: Timestamp,
    content: String,
    complete: Bool,
    ownerId: String
  ) {
    self.id = id
    self.date = date
    self.content = content
    self.complete = complete
    self.ownerId = ownerId
  }

  public static let skeleton: [Schedule] =
  (0...4).map { _ in
      .init(
        date: .init(date: Date()),
        content: String(repeating: " ", count: 10),
        complete: false,
        ownerId: ""
      )
  }
}
