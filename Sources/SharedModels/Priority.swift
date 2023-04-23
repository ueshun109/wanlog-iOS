public enum Priority: String, Codable, CaseIterable {
  case special
  case high
  case medium
  case low

  public var title: String {
    switch self {
    case .special:
      return ""
    case .high:
      return "高"
    case .medium:
      return "中"
    case .low:
      return "低"
    }
  }
}
