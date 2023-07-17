import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Dog: Identifiable, Codable, Hashable {
  /// Identifier
  @DocumentID public var id: String?
  /// Dog name.
  public var name: String
  /// Birth date.
  public var birthDate: Timestamp
  /// Biological sex.
  public var biologicalSex: BiologicalSex
  /// Dog icon reference for Firebase Storage
  public var iconRef: String?
  /// Types of preventive drugs.
  public var preventions: Preventions

  /// Create instance
  /// - Parameters:
  ///   - id: Identifier
  ///   - name: Dog name
  ///   - birthDate: Birth date
  ///   - biologicalSex: Biological sex
  ///   - iconRef: Dog icon reference for Firebase Storage
  ///   - preventions: Types of preventive drugs.
  public init(
    id: String? = nil,
    name: String,
    birthDate: Timestamp,
    biologicalSex: BiologicalSex,
    iconRef: String? = nil,
    preventions: Preventions
  ) {
    self.id = id
    self.name = name
    self.birthDate = birthDate
    self.biologicalSex = biologicalSex
    self.iconRef = iconRef
    self.preventions = preventions
  }

  public static let skelton: [Dog] = (0...2).map { i in
      .init(
        name: String(repeating: " ", count: 10),
        birthDate: .init(date: Date()),
        biologicalSex: .male,
        preventions: .fake
      )
  }
}
