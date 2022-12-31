import SharedModels
@_exported import FirebaseFirestore
@_exported import FirebaseFirestoreSwift

public enum Query {
  case certificate(Certificate)
  case dog(Dog)
  case schedule(Schedule)

  public enum Certificate {
    case all(uid: String)
    case perDog(uid: String, dogId: String)
    case one(uid: String, dogId: String, certificateId: String)

    public func collection() -> FirebaseFirestore.CollectionReference {
      let db = Firestore.firestore()
      switch self {
      case .all:
        fatalError("Use query()")
      case .perDog(let uid, let dogId):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
          .document(dogId)
          .collection("certificates")
      case .one:
        fatalError("Call the document function to get a single data")
      }
    }

    /// Return a DocumentReference to get a certificate of a dog owned by a user.
    /// - Returns: FirebaseFirestore.DocumentReference
    public func document() -> FirebaseFirestore.DocumentReference {
      let db = Firestore.firestore()
      switch self {
      case .all, .perDog:
        fatalError("Call the query function to get the list data")
      case .one(let uid, let dogId, let certificateId):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
          .document(dogId)
          .collection("certificates")
          .document(certificateId)
      }
    }

    /// Return a Query to get all certificates of dogs owned by a user.
    /// - Returns: FirebaseFirestore.CollectionReference
    public func query() -> FirebaseFirestore.Query {
      let db = Firestore.firestore()
      switch self {
      case .all(let uid):
        return db.collectionGroup("certificates")
          .whereField("ownerId", isEqualTo: uid)
          .order(by: "date", descending: false)
      case .perDog(let uid, let dogId):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
          .document(dogId)
          .collection("certificates")
      case .one:
        fatalError("Call the query function to get a single data")
      }
    }
  }

  public enum Dog {
    case all(uid: String)
    case one(uid: String, dogId: String)

    /// Return a DocumentReference to get a single a dog owned by a user.
    /// - Returns: FirebaseFirestore.DocumentReference
    public func document() -> FirebaseFirestore.DocumentReference {
      let db = Firestore.firestore()
      switch self {
      case .all:
        fatalError("Call the query function to get the list data")
      case .one(let uid, let dogId):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
          .document(dogId)
      }
    }

    /// Return a CollectionReference to get all dogs owned by a user.
    /// - Returns: FirebaseFirestore.CollectionReference
    public func collection() -> FirebaseFirestore.CollectionReference {
      let db = Firestore.firestore()
      switch self {
      case .all(let uid):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
      case .one:
        fatalError("Call the query function to get a single data")
      }
    }
  }

  public enum Schedule {
    case all(uid: String)
    case perDog(uid: String, dogId: String)
    case one(uid: String, dogId: String, scheduleId: String)


    /// Return a CollectionReference to get schedules for all dogs or specified a dog owned by a user.
    /// - Returns: FirebaseFirestore.CollectionReference
    public func collection() -> FirebaseFirestore.CollectionReference {
      let db = Firestore.firestore()
      switch self {
      case .all, .one:
        fatalError("Correspond only perDog")
      case .perDog(let uid, let dogId):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
          .document(dogId)
          .collection("schedules")
      }
    }

    /// Return a DocumentReference to get a single schedule for specified a dog owned by a user.
    /// - Returns: FirebaseFirestore.DocumentReference
    public func document() -> FirebaseFirestore.DocumentReference {
      let db = Firestore.firestore()
      switch self {
      case .all, .perDog:
        fatalError("Call the query function to get the list data")
      case .one(let uid, let dogId, let scheduleId):
        return db.collection("owners")
          .document(uid)
          .collection("dogs")
          .document(dogId)
          .collection("schedules")
          .document(scheduleId)
      }
    }

    /// Return a Query to get schedules for all dogs or specified a dog owned by a user.
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
      case .one:
        fatalError("Call the query function to get a single data")
      }
    }
  }
}
