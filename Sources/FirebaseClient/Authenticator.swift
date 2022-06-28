import CryptoKit
import SharedModels
@_exported import FirebaseAuth

public enum Authenticator {
  case live
  case mock
  case failed

  public func signUp(email: String, password: String) async throws {
    switch self {
    case .live:
      do {
        try await Auth.auth().createUser(withEmail: email, password: password)
      } catch {
        let error = handleError(error: error)
        throw LoadingError(
          errorDescription: "登録エラー",
          failureReason: error.title,
          recoverySuggestion: nil,
          recoveryAction: error.recoveryAction
        )
      }
    case .mock:
      break
    case .failed:
      throw LoadingError(errorDescription: "ネットワークエラー")
    }
  }

  /// 匿名認証を実行する
  public func anonymousSignin() async throws -> Bool {
    switch self {
    case .live:
      do {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.isAnonymous
      } catch {
        let error = handleError(error: error)
        throw LoadingError(
          errorDescription: "エラー",
          failureReason: error.title,
          recoverySuggestion: nil,
          recoveryAction: error.recoveryAction
        )
      }
    case .mock:
      return true
    case .failed:
      throw LoadingError(errorDescription: "ネットワークエラー")
    }
  }

  public func user() async -> User? {
    switch self {
    case .live:
      return Auth.auth().currentUser
    case .mock:
      return nil
    case .failed:
      return nil
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

  /// Handle error
  ///
  /// seealso: - [Error Type](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/Error-Types)
  private func handleError(error: Error) -> FirebaseAuthError {
    let errorCode = AuthErrorCode(_nsError: error as NSError).code
    switch errorCode {
    case .appNotAuthorized, .invalidAPIKey, .operationNotAllowed:
      fatalError("無効なAPIKeyが使用されているか、使用が許可されていません。")
    case .emailAlreadyInUse: return .alreadyInUse
    case .internalError: return .server
    case .invalidEmail, .wrongPassword: return .wrongEmailOrPassword
    case .networkError: return .disconnectNetwork
    case .tooManyRequests: return .tooManyRequest
    case .userDisabled: return .disabledUser
    case .userNotFound: return .notFound
    case .userTokenExpired: return .expiredToken
    default: return .unknown
    }
  }
}

private extension Authenticator {
  func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError(
            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
          )
        }
        return random
      }

      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }

        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }

    return result
  }

  func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()

    return hashString
  }
}
