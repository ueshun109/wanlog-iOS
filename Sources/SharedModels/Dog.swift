import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Dog: Identifiable, Codable {
  @DocumentID public var id: String?
  public let name: String
  public let birthDate: Timestamp
  public let biologicalSex: BiologicalSex

  public init(
    id: String? = nil,
    name: String,
    birthDate: Timestamp,
    biologicalSex: BiologicalSex
  ) {
    self.id = id
    self.name = name
    self.birthDate = birthDate
    self.biologicalSex = biologicalSex
  }
}
