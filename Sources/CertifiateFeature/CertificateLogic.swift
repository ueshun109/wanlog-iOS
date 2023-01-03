import FirebaseClient
import SharedModels
import SwiftUI

/// Generate a dictionary with keys as dates and values as arrays and dictionary keys from certificate array.
/// - Parameter certificates: `Certificate` array
/// - Returns: Tuple
func dictionaryAndKeys(from certificates: [Certificate]) -> (dictionary: [Date: [Certificate]], keys: [Date]) {
  let dic = Dictionary(grouping: certificates) { certificate -> Date in
    let components = Calendar.current.dateComponents(
      [.calendar, .year, .month, .day],
      from: certificate.date.dateValue()
    )
    return components.date!
  }
  let keys = dic.map(\.key).sorted(by: { $0 > $1 })
  return (dic, keys)
}

/// Validate certificate data.
/// - Parameters:
///   - title: certificate title.
///   - images: certificate images.
///   - dog: associated dog.
/// - Returns: If data is valid, return `true`.
func validateCertificate<Images: Collection>(
  title: String,
  images: Images,
  dog: Dog?
) -> Bool {
  !title.isEmpty && images.count >= 1 && dog != nil
}
