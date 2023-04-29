import Core
import SharedModels
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift

public extension FirebaseFirestore.Firestore {
  func get<T>(query: FirebaseFirestore.Query, type: T.Type) async throws -> [T]? where T: Decodable {
    do {
      let querySnapshot = try await query.getDocuments()
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
        throw LoadingError(errorDescription: error.localizedDescription)
      }
    }
  }

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
        throw LoadingError(errorDescription: error.localizedDescription)
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
        throw LoadingError(errorDescription: error.localizedDescription)
      }
    }
  }

  func listen<T>(_ reference: FirebaseFirestore.Query, type: T.Type) -> AsyncThrowingStream<[T], Error> where T: Decodable {
    AsyncThrowingStream { continuation in
      let listener = reference.addSnapshotListener { querySnapshot, error in
        if let error = error {
          continuation.finish(throwing: error); return
        }
        do {
          let response: [T] = try querySnapshot?.documents.compactMap { queryDocumentSnapshot in
            return try queryDocumentSnapshot.data(as: type)
          } ?? []
          continuation.yield(response)
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { @Sendable _ in
        listener.remove()
      }
    }
  }

  @discardableResult
  func set<T>(_ data: T, collectionReference: CollectionReference) async throws -> DocumentReference where T: Encodable {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<DocumentReference, Error>) in
      do {
        var docRef: DocumentReference?
        docRef = try collectionReference.addDocument(from: data) { error in
          if let error = error,
             let loadingError = self?.handleError(error: error)?.toLoadingError {
            logger.error(message: error)
            continuation.resume(throwing: loadingError)
            return
          }
          logger.info(message: "Succeeded in adding")
          continuation.resume(returning: docRef!)
        }
        logger.info(message: "docRef: \(String(describing: docRef))")
      } catch {
        logger.error(message: error)
        if let loadingError = self?.handleError(error: error)?.toLoadingError {
          continuation.resume(throwing: loadingError)
        } else {
          let loadingError = LoadingError(errorDescription: error.localizedDescription)
          continuation.resume(throwing: loadingError)
        }
      }
    }
  }

  func set<T>(_ data: T, documentReference: DocumentReference) async throws where T: Encodable {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      do {
        try documentReference.setData(from: data) { error in
          if let error = error,
             let loadingError = self?.handleError(error: error)?.toLoadingError {
            logger.error(message: error)
            continuation.resume(throwing: loadingError)
            return
          }
          logger.info(message: "Succeeded in setting")
          continuation.resume()
        }
      } catch {
        logger.error(message: error)
        if let loadingError = self?.handleError(error: error)?.toLoadingError {
          continuation.resume(throwing: loadingError)
        } else {
          let loadingError = LoadingError(errorDescription: error.localizedDescription)
          continuation.resume(throwing: loadingError)
        }
      }
    }
  }

  /// Remove document.
  /// - Parameter documentReference: `DocumentReference`
  func remove(_ documentReference: DocumentReference) async throws {
    try await documentReference.delete()
  }

  func updates<T>(
    _ targets: [(data: T, reference: DocumentReference)],
    removeFields: Dictionary<String, FieldValue>? = nil
  ) async throws where T: Encodable {
    let batch = batch()
    let encoder = Firestore.Encoder()
    for target in targets {
      let fields = try encoder.encode(target.data)
      batch.updateData(fields, forDocument: target.reference)
      if let removeFields {
        batch.updateData(removeFields, forDocument: target.reference)
      }
    }
    try await batch.commit()
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
