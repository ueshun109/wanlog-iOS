import Core
import SharedModels
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift

public extension FirebaseFirestore.Firestore {
  func get<T>(_ reference: CollectionReference, type: T.Type) async throws -> [T]? where T: Decodable {
    do {
      let querySnapshot = try await reference.getDocuments()
      let response: [T]? = try querySnapshot.documents.compactMap { queryDocumentSnapshot in
        return try queryDocumentSnapshot.data(as: type)
      }
      logger.info(message: "Succeeded in getting: \(String(describing: response))")
      return response
    } catch {
      logger.error(message: error)
      if let loadingError = handleError(error: error)?.toLoadingError {
        throw loadingError
      } else {
        throw error
      }
    }
  }

  func get<T>(_ reference: DocumentReference, type: T.Type) async throws -> T? where T: Decodable {
    do {
      let documentSnapshot = try await reference.getDocument()
      let response: T? = try documentSnapshot.data(as: type)
      logger.info(message: "Succeeded in getting: \(String(describing: response))")
      return response
    } catch {
      logger.error(message: error)
      if let loadingError = handleError(error: error)?.toLoadingError {
        throw loadingError
      } else {
        throw error
      }
    }
  }

  func set<T>(_ data: T, reference: CollectionReference) async throws where T: Encodable {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      do {
        let docRef = try reference.addDocument(from: data) { error in
          if let error = error,
             let loadingError = self?.handleError(error: error)?.toLoadingError {
            logger.error(message: error)
            continuation.resume(throwing: loadingError)
            return
          }
          logger.info(message: "Succeeded in adding")
          continuation.resume()
        }
        logger.info(message: "docRef: \(docRef)")
      } catch {
        logger.error(message: error)
        if let loadingError = self?.handleError(error: error)?.toLoadingError {
          continuation.resume(throwing: loadingError)
        } else {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  /// Handle error
  ///
  /// seealso: - [Error Type](https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Enums/Error-Types)
  private func handleError(error: Error) -> FirestoreError? {
    let errorCode = FirestoreErrorCode(_nsError: error as NSError).code
    switch errorCode {
    case .cancelled: return nil
    case .invalidArgument: return .badRequest
    case .deadlineExceeded: return .timeout
    case .notFound: return .notFound
    case .alreadyExists: return .alreadyExists
    case .permissionDenied, .unauthenticated: return .notAuthorized
    default: return .unknown
    }
  }
}
