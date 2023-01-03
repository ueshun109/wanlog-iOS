import Core
import FirebaseClient
import SharedModels
import UIKit

public extension CertificateUsecase {
  class GetCertificateList: ObservableObject {
    private let authenticator: Authenticator = .live
    private let db = Firestore.firestore()

    func callAsFunction() async throws {
    }
  }

  struct GetCertificateItem {
    private let db = Firestore.firestore()

    public func callAsFunction(reference: DocumentReference) async throws -> Certificate? {
      try await db.get(reference, type: Certificate.self)
    }
  }

  struct GetImageList {
    private let storage: Storage = .storage()

    public func callAsFunction(references: [String]) async throws -> [UIImage] {
      var images: [UIImage] = []
      for reference in references {
        guard let data = try? await storage.reference(withPath: reference).get(),
              let image = UIImage(data: data)
        else { continue }
        images.append(image)
      }
      return images
    }
  }
}
