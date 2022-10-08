import FirebaseClient
import SharedModels
import SwiftUI

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

/// Save certificate data.
/// - Parameters:
///   - certificate: `Certificate`
///   - uid: user id
///   - dogId: dog id
/// - Throws: `LoadingError`
/// - Returns: If the save succeededs, return `DocumentReference`.
func save(
  _ certificate: Certificate,
  uid: String,
  dogId: String
) async throws -> DocumentReference {
  let db = Firestore.firestore()
  let query: Query.Certificate = .perDog(uid: uid, dogId: dogId)
  return try await db.set(certificate, collectionReference: query.collection())
}

/// Save certificate images.
/// - Parameters:
///   - images: images
///   - uid: user id
///   - dogId: dog id
///   - certificateTitle: use for image file name.
/// - Throws: `LoadingError`
/// - Returns: If the save succeededs, return ``.
func save<Images: Collection>(
  _ images: Images,
  uid: String,
  dogId: String,
  certificateTitle: String
) async throws -> [String] where Images.Element == UIImage? {
  let oneMB = 1024 * 1024
  var storagePaths: [String] = []
  for (index, image) in images.enumerated() {
    guard let image else { continue }
    let storageRef = Storage.storage().certificateRef(
      uid: uid,
      dogId: dogId,
      fileName: "\(certificateTitle)-\(index)"
    )
    if image.exceed(oneMB) {
      let data = image.resize(to: oneMB)
      try await storageRef.upload(data)
    } else if let data = image.pngData() {
      try await storageRef.upload(data)
    }
    storagePaths.append(storageRef.fullPath)
  }
  return storagePaths
}
