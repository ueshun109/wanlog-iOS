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

/// Save certificate data.
/// - Parameters:
///   - certificate: `Certificate`
///   - uid: user id
///   - dogId: dog id
/// - Throws: `LoadingError`
/// - Returns: If the save succeededs, return `DocumentReference`.
func save(
  certificate: Certificate,
  uid: String,
  dogId: String
) async throws -> DocumentReference {
  let db = Firestore.firestore()
  let query: Query.Certificate = .perDog(uid: uid, dogId: dogId)
  return try await db.set(certificate, collectionReference: query.collection())
}

/// Update certificate data.
/// - Parameters:
///   - certificate: `Certificate`
///   - uid: user id
///   - dogId: dog id
///   - certificateId:
/// - Throws:
func update(
  certificate: Certificate,
  uid: String,
  dogId: String,
  certificateId: String
) async throws {
  let db = Firestore.firestore()
  let query: Query.Certificate = .one(uid: uid, dogId: dogId, certificateId: certificateId)
  try await db.set(certificate, documentReference: query.document())
}

/// Save certificate images.
/// - Parameters:
///   - images: images
///   - uid: user id
///   - dogId: dog id
///   - certificateTitle: use for image file name.
/// - Throws: `LoadingError`
/// - Returns: If the save succeededs, return ``.
//func save(
//  images: [UIImage?],
//  uid: String,
//  dogId: String,
//  certificateTitle: String
//) async throws -> [String] {
//  let oneMB = 1024 * 1024
//  var storagePaths: [String] = []
//  for (index, image) in images.enumerated() {
//    guard let image else { continue }
//    let storageRef = Storage.storage().certificateRef(
//      uid: uid,
//      dogId: dogId,
//      fileName: "\(certificateTitle)-\(index + 1)"
//    )
//    if image.exceed(oneMB) {
//      let data = image.resize(to: oneMB)
//      try await storageRef.upload(data)
//    } else if let data = image.pngData() {
//      try await storageRef.upload(data)
//    }
//    storagePaths.append(storageRef.fullPath)
//  }
//  return storagePaths
//}

func create(
  images: [UIImage?],
  uid: String,
  dogId: String,
  folderName: String,
  existedImageCount: Int
) async throws -> [String] {
  let oneMB = 1024 * 1024
  var storagePaths: [String] = []
  for (index, image) in images.enumerated() {
    guard let image else { continue }
    let storageRef = Storage.storage().certificateRef(
      uid: uid,
      dogId: dogId,
      folderName: folderName,
      fileName: "\(existedImageCount + index + 1)"
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

func update(items: [String: UIImage?]) async throws {
  let oneMB = 1024 * 1024
  for item in items {
    guard let image = item.value else { continue }
    let storageRef = Storage.storage().reference(from: item.key)
    if image.exceed(oneMB) {
      let data = image.resize(to: oneMB)
      try await storageRef.upload(data)
    } else if let data = image.pngData() {
      try await storageRef.upload(data)
    }
  }
}

func remove(paths: [String]) async throws {
  for path in paths {
    let storageRef = Storage.storage().reference(from: path)
    try await storageRef.delete()
  }
}

//func save(
//  image: UIImage,
//  uid: String,
//  dogId: String,
//  fileName: String
//) async throws -> String {
//  let oneMB = 1024 * 1024
//  let storageRef = Storage.storage().certificateRef(uid: uid, dogId: dogId, fileName: fileName)
//  if image.exceed(oneMB) {
//    let data = image.resize(to: oneMB)
//    try await storageRef.upload(data)
//  } else if let data = image.pngData() {
//    try await storageRef.upload(data)
//  }
//  return storageRef.fullPath
//}
