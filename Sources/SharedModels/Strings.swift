import Foundation

enum LocalizedKey: String {
  // Prevention
  case combinationVaccine = "Combination vaccine"
  case combinationVaccination = "Combination vaccination"
  case heartwormPill = "Heartworm pill"
  case giveHeartwormPill = "Give heartworm pill"
  case rabiesVaccine = "Rabies vaccine"
  case rabiesVaccination = "Rabies vaccination"

  // Biological sex
  case male = "Male"
  case female = "Female"

  // Priority
  case high = "High"
  case medium = "Medium"
  case low = "Low"

  var localized: String {
      NSLocalizedString(self.rawValue, bundle: .module, comment: "")
  }
}

extension String {
  static let localized: (LocalizedKey) -> String = { key in
    NSLocalizedString(key.rawValue, bundle: .module, comment: "")
  }
}
