import Foundation

extension Dog {
  public enum BiologicalSex: String, Codable, Hashable, Identifiable, CaseIterable, Equatable {
    case male
    case female

    public var id: String {
      switch self {
      case .male:
        return "male"
      case .female:
        return "female"
      }
    }

    public var title: String {
      switch self {
      case .male:
        return .localized(.male)
      case .female:
        return .localized(.female)
      }
    }
  }
}
