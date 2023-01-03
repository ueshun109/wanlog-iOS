import FirebaseClient
import SharedModels

public extension DogUsecase {
  struct GetDogList {
    private let authenticator: Authenticator = .live
    private let db = Firestore.firestore()

    public func callAsFunction() async throws -> [Dog] {
      guard let uid = await authenticator.user()?.uid else { return [] }
      let query: Query.Dog = .all(uid: uid)
      guard let dogs = try await db.get(query: query.collection(), type: Dog.self) else { return [] }
      return dogs
    }
  }
}
