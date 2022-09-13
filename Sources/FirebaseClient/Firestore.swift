import Core
import SharedModels
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift

public enum Query {
  case schedule(Schedule)

  public enum Schedule {
    case all(uid: String)
    case perDog(uid: String, dogId: String)

    /// Return a query to get schedules for all dogs or specified a dog owned by a user.
    /// - Parameters:
    ///   - incompletedOnly: Whether to get only incompleted schedules.
    /// - Returns: `Query`
    public func query(incompletedOnly: Bool = true) -> FirebaseFirestore.Query {
      let db = Firestore.firestore()
      switch self {
      case .all(let uid):
        if incompletedOnly {
          return db.collectionGroup("schedules")
            .whereField("ownerId", isEqualTo: uid)
            .whereField("complete", isEqualTo: false)
            .order(by: "date", descending: false)
        } else {
          return db.collectionGroup("schedules")
            .whereField("ownerId", isEqualTo: uid)
            .order(by: "complete", descending: false)
            .order(by: "date", descending: false)
        }
      case let .perDog(uid, dogId):
        if incompletedOnly {
          return db
            .collection("owners")
            .document(uid)
            .collection("dogs")
            .document(dogId)
            .collection("schedules")
            .whereField("complete", isEqualTo: false)
            .order(by: "date", descending: false)
        } else {
          return db
            .collection("owners")
            .document(uid)
            .collection("dogs")
            .document(dogId)
            .collection("schedules")
            .order(by: "complete", descending: false)
            .order(by: "date", descending: false)
        }
      }
    }
  }

  static func schedules(
    uid: String,
    dogId: String,
    scheduleId: String,
    incompletedOnly: Bool = true
  ) -> FirebaseFirestore.Query {
    let db = Firestore.firestore()
    if incompletedOnly {
      return db
        .collection("owners")
        .document(uid)
        .collection("dogs")
        .document(dogId)
        .collection("schedules")
        .whereField("complete", isEqualTo: false)
        .order(by: "date", descending: false)
    } else {
      return db
        .collection("owners")
        .document(uid)
        .collection("dogs")
        .document(dogId)
        .collection("schedules")
        .order(by: "complete", descending: false)
        .order(by: "date", descending: false)
    }
  }
}

public extension FirebaseFirestore.Firestore {
  func schedule(
    uid: String,
    dogId: String,
    scheduleId: String
  ) -> DocumentReference {
    collection("owners")
      .document(uid)
      .collection("dogs")
      .document(dogId)
      .collection("schedules")
      .document(scheduleId)
  }

  func dog(
    uid: String,
    dogId: String
  ) -> DocumentReference {
    collection("owners")
      .document(uid)
      .collection("dogs")
      .document(dogId)
  }

  func dogs(uid: String) -> CollectionReference {
    collection("owners")
      .document(uid)
      .collection("dogs")
  }

  func schedules(uid: String, dogId: String) -> CollectionReference {
    collection("owners")
      .document(uid)
      .collection("dogs")
      .document(dogId)
      .collection("schedules")
  }
}

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

  func set<T>(_ data: T, reference: CollectionReference) async throws -> DocumentReference where T: Encodable {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<DocumentReference, Error>) in
      do {
        var docRef: DocumentReference?
        docRef = try reference.addDocument(from: data) { error in
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

  func set<T>(data: T, reference: DocumentReference) async throws where T: Encodable {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      do {
        try reference.setData(from: data) { error in
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

  func updates<T>(_ targets: [(data: T, reference: DocumentReference)]) async throws where T: Encodable {
    let batch = batch()
    let encoder = Firestore.Encoder()
    for target in targets {
      let fields = try encoder.encode(target.data)
      batch.updateData(fields, forDocument: target.reference)
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
