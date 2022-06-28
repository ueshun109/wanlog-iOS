import Foundation
import SharedModels
@_exported import FirebaseClient

@MainActor
public class DogState: ObservableObject {
  @Published public private(set) var dogs: [Dog] = []
  @Published public private(set) var error: LoadingError?
  private let authenticator: Authenticator
  private let db = Firestore.firestore()

  public init(authenticator: Authenticator) {
    self.authenticator = authenticator
  }

  public func getDogs() async {
    do {
      guard let uid = await authenticator.user()?.uid else {
        throw FirestoreError.notAuthorized.toLoadingError
      }
      let ref = db.collection("/owners/\(uid)/dogs")
      guard let dogs = try await db.get(ref, type: Dog.self) else {
        throw FirestoreError.notFound.toLoadingError
      }
      self.dogs = dogs
    } catch let loadingError as LoadingError {
      self.error = loadingError
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      self.error = loadingError
    }
  }

  public func add(_ dog: Dog) async {
    do {
      guard let uid = await authenticator.user() else {
        throw FirestoreError.notAuthorized.toLoadingError
      }
      let collection = db.collection("owners/\(uid)/dogs")
      try await db.set(dog, reference: collection)
    } catch let loadingError as LoadingError {
      self.error = loadingError
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      self.error = loadingError
    }
  }
}
