import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Certificate: Codable, Equatable, Identifiable, Hashable {
  @DocumentID public var id: String?
  public var dogId: String
  public var title: String
  public var description: String?
  public var imageRefs: [String]
  public var date: Timestamp
  public var ownerId: String
  @ServerTimestamp public var createdAt: Timestamp?

  public init(
    dogId: String,
    title: String,
    description: String? = nil,
    imageRefs: [String],
    date: Timestamp,
    ownerId: String
  ) {
    self.dogId = dogId
    self.title = title
    self.description = description
    self.imageRefs = imageRefs
    self.date = date
    self.ownerId = ownerId
  }

  public static let skelton: [Certificate] = (0...2).map { i in
      .init(
        dogId: "\(i)",
        title: String(repeating: " ", count: 10),
        imageRefs: [""],
        date: .init(date: Date()),
        ownerId: ""
      )
  }

  public static let fake: Certificate = .init(
    dogId: "",
    title: "タイトル",
    imageRefs: [],
    date: .init(date: .now),
    ownerId: ""
  )
}
