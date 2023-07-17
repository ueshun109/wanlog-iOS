extension Todo {
  public enum Priority: String, Codable, CaseIterable {
    case high
    case medium
    case low

    public var title: String {
      switch self {
      case .high:
        return .localized(.high)
      case .medium:
        return .localized(.medium)
      case .low:
        return .localized(.low)
      }
    }
  }
}

