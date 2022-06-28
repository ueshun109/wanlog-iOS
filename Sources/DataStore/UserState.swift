import Foundation
import SharedModels
@_exported import FirebaseClient

@MainActor
public final class UserState: ObservableObject {
  @Published public private(set) var isSignIn = false
  @Published public private(set) var error: LoadingError?
  private let authenticator: Authenticator
  private let db = Firestore.firestore()

  public init(authenticator: Authenticator) {
    self.authenticator = authenticator
  }

  public func confirmAuthStatus() async {
    isSignIn = await authenticator.isSignIn()
  }

  public func anonymousSignin() async {
    do {
      isSignIn = try await authenticator.anonymousSignin()
      if let user = await authenticator.user() {
        let ref = db.collection("owners").document(user.uid)
        try? await ref.setData([:])
      }
    } catch let loadingError as LoadingError {
      self.error = loadingError
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      self.error = loadingError
    }
  }

  public func currentUser() async -> User? {
    guard let user = await authenticator.user() else { return nil }
    do {
      // Check if the user id is registerd in the firestore.
      let _ = try await db.document("owners/\(user.uid)").getDocument()
    } catch {
      // If the user id is not registerd in the firestore, register it.
      let ref = db.collection("owners").document(user.uid)
      try? await ref.setData([:])
    }
    return await authenticator.user()
  }

  public func signUp(email: String, password: String) async {
    do {
      try await authenticator.signUp(email: email, password: password)
    } catch let loadingError as LoadingError {
      self.error = loadingError
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      self.error = loadingError
    }
  }
}
