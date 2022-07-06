import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Dog: Identifiable, Codable {
  @DocumentID public var id: String?
  public var name: String
  public var birthDate: Timestamp
  public var biologicalSex: BiologicalSex

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
