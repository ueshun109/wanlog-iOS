import FirebaseAuth
import SharedModels

public enum Authenticator {
  case live
  case mock
  case failed

  /// 匿名認証を実行する
  public func anonymousSignin() async throws -> Bool {
    switch self {
    case .live:
      do {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.isAnonymous
      } catch {
        throw LoadingError(
          errorDescription: error.localizedDescription,
          recoverySuggestion: "再度試してみてください",
          recoveryAction: .reload
        )
      }
    case .mock:
      return true
    case .failed:
      throw LoadingError(errorDescription: "ネットワークエラー")
    }
  }

  /// ログイン済みかどうか
  public func isSignIn() async -> Bool {
    switch self {
    case .live:
      return Auth.auth().currentUser != nil
    case .mock:
      return true
    case .failed:
      return false
    }
  }
}
