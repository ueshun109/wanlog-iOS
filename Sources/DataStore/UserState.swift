import Combine
import FirebaseClient
import Foundation
import SharedModels

@MainActor
public final class UserState: ObservableObject {
  private let authenticator: Authenticator
  @Published public private(set) var isSignIn = false
  public private(set) var error = PassthroughSubject<LoadingError, Never>()

  public init(authenticator: Authenticator) {
    self.authenticator = authenticator
  }

  public func confirmAuthStatus() async {
    isSignIn = await authenticator.isSignIn()
  }

  public func anonymousSignin() async {
    do {
      isSignIn = try await authenticator.anonymousSignin()
    } catch let loadingError as LoadingError {
      self.error.send(loadingError)
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      self.error.send(loadingError)
    }
  }

  public func signUp(email: String, password: String) async {
    do {
      try await authenticator.signUp(email: email, password: password)
    } catch let loadingError as LoadingError {
      self.error.send(loadingError)
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      self.error.send(loadingError)
    }
  }
}
