import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Certificate: Codable, Equatable, Identifiable {
  @DocumentID public var id: String?
  public var dogId: String
  public var title: String
  public var description: String?
  public var imageRef: [String]
  public var date: Timestamp

  public init(
    dogId: String,
    title: String,
    description: String? = nil,
    imageRef: [String],
    date: Timestamp
  ) {
    self.dogId = dogId
    self.title = title
    self.description = description
    self.imageRef = imageRef
    self.date = date
  }

  public static let skelton: [Certificate] = (0...2).map { i in
      .init(dogId: "\(i)", title: String(repeating: " ", count: 10), imageRef: [""], date: .init(date: Date()))
  }
}
