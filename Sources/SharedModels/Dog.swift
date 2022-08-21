import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Dog: Identifiable, Codable, Hashable {
  @DocumentID public var id: String?
  public var name: String
  public var birthDate: Timestamp
  public var biologicalSex: BiologicalSex
  public var iconRef: String?

  public init(
    id: String? = nil,
    name: String,
    birthDate: Timestamp,
    biologicalSex: BiologicalSex,
    iconRef: String? = nil
  ) {
    self.id = id
    self.name = name
    self.birthDate = birthDate
    self.biologicalSex = biologicalSex
    self.iconRef = iconRef
  }

  public static let skelton: [Dog] = (0...2).map { i in
      .init(
        name: String(repeating: " ", count: 10),
        birthDate: .init(date: Date()),
        biologicalSex: .male
      )
  }
}
