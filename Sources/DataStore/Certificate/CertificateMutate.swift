import Core
import FirebaseClient
import SharedModels
import UIKit

public extension CertificateUsecase {
  struct CreateCertificate {
    let db = Firestore.firestore()

    public func callAsFunction(certificate: Certificate, images: LimitedArray<UIImage?>) async throws {
      let getItem = CertificateUsecase.getCertificateItem
      let postImage = UploadImageList()
      // Create certificate to firestore
      let documentRef = try await create(certificate: certificate)

      // Create certificate images to Firebase Storage
      guard let certificate = try await getItem(reference: documentRef) else { return }
      let createdPaths = try await postImage.create(images: images.map { $0 }, certificate: certificate)

      // Update certificate references
      var new = certificate
      new.imageRefs = createdPaths
      try await update(certificate: new)
    }

    private func create(certificate: Certificate) async throws -> DocumentReference {
      let query: Query.Certificate = .perDog(
        uid: certificate.ownerId,
        dogId: certificate.dogId
      )
      return try await db.set(certificate, collectionReference: query.collection())
    }

    private func update(certificate: Certificate) async throws {
      let query: Query.Certificate = .one(
        uid: certificate.ownerId,
        dogId: certificate.dogId,
        certificateId: certificate.id!
      )
      try await db.set(certificate, documentReference: query.document())
    }
  }

  struct SaveCertificate {
    public func callAsFunction(
      _ certificate: Certificate,
      diff: CollectionDifferenceType<LimitedArray<UIImage?>>
    ) async throws {
      let post = UploadImageList()
      switch diff {
      case .onlyUpdated(let updated):
        let pathsAndImages = Dictionary(uniqueKeysWithValues: zip(certificate.imageRefs, updated))
        try await post.update(pathsAndImages)
        try await upload(certificate: certificate)
      case .increased(let updated, let inserted):
        // Update images.
        let updatedPathsAndImages = Dictionary(uniqueKeysWithValues: zip(certificate.imageRefs, updated))
        try await post.update(updatedPathsAndImages)
        let createdPaths = try await post.create(images: inserted, certificate: certificate)
        let newImageRefs = certificate.imageRefs + createdPaths
        // Update firestore scheme.
        var new = certificate
        new.imageRefs = newImageRefs
        try await upload(certificate: new)
      case .decreased(let updated, _):
        // Update images.
        let updatedPathsAndImages = Dictionary(uniqueKeysWithValues: zip(certificate.imageRefs, updated))
        try await post.remove(paths: certificate.imageRefs)
        try await post.update(updatedPathsAndImages)
        // Update firestore scheme.
        let newImageRefs: [String] = Array(updatedPathsAndImages.keys)
        var new = certificate
        new.imageRefs = newImageRefs
        try await upload(certificate: new)
      case .noChange:
        try await upload(certificate: certificate)
      }
    }

    private func upload(certificate: Certificate) async throws {
      let db = Firestore.firestore()
      let query: Query.Certificate = .one(
        uid: certificate.ownerId,
        dogId: certificate.dogId,
        certificateId: certificate.id!
      )
      try await db.set(certificate, documentReference: query.document())
    }
  }

  struct UploadImageList {
    func create(images: [UIImage?], certificate: Certificate) async throws -> [String] {
      let oneMB = 1024 * 1024
      var storagePaths: [String] = []
      for (index, image) in images.enumerated() {
        guard let image else { continue }
        let storageRef = Storage.storage().certificateRef(
          uid: certificate.ownerId,
          dogId: certificate.dogId,
          folderName: certificate.createdAt!.dateValue().ISO8601Format(),
          fileName: "\(certificate.imageRefs.count + index + 1)"
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

    func remove(paths: [String]) async throws {
      for path in paths {
        let storageRef = Storage.storage().reference(from: path)
        try await storageRef.delete()
      }
    }

    func update(_ pathAndImages: [String: UIImage?]) async throws {
      let oneMB = 1024 * 1024
      for (path, image) in pathAndImages {
        guard let image = image else { continue }
        let storageRef = Storage.storage().reference(from: path)
        if image.exceed(oneMB) {
          let data = image.resize(to: oneMB)
          try await storageRef.upload(data)
        } else if let data = image.pngData() {
          try await storageRef.upload(data)
        }
      }
    }
  }
}
