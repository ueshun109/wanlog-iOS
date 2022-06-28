import FirebaseFirestore

public struct Schedule: Codable {
  public let date: Timestamp
  public let content: String
}
