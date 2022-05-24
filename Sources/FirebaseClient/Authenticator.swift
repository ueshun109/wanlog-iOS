import FirebaseAuth
import SharedModels

public struct FirebaseAuthError {
  public let title: String
  public let recoveryAction: RecoveryAction?
}

public extension FirebaseAuthError {
  static let alreadyInUse = FirebaseAuthError(
    title: "このメールアドレスはすでに使用されています。別のメールアドレスで登録してください。",
    recoveryAction: nil
  )
  static let disabledUser = FirebaseAuthError(
    title: "このユーザーのアカウントが無効になっています。",
    recoveryAction: nil
  )
  static let disconnectNetwork = FirebaseAuthError(
    title: "ネットワークエラー",
    recoveryAction: .reload
  )
  static let expiredToken = FirebaseAuthError(
    title: "トークンの有効期限が切れています。再度ログインしてください。",
    recoveryAction: .login
  )
  static let failedSettingName = FirebaseAuthError(
    title: "名前の保存に失敗しました。再度名前を登録してください。",
    recoveryAction: nil
  )
  static let failedEmail = FirebaseAuthError(
    title: "メールアドレスの保存に失敗しました。再度メールアドレスを登録してください。",
    recoveryAction: nil
  )
  static let notFound = FirebaseAuthError(
    title: "このユーザーは存在しません。他のユーザーでログインしてください。",
    recoveryAction: nil
  )
  static let server = FirebaseAuthError(
    title: "サーバーでエラーが発生しました。お手数ですが、時間を置いて再度試してみてください。",
    recoveryAction: nil
  )
  static let tooManyRequest = FirebaseAuthError(
    title: "時間を置いてから再度実施してください。",
    recoveryAction: nil
  )
  static let unknown = FirebaseAuthError(
    title: "不明なエラー",
    recoveryAction: nil
  )
  static let wrongEmailOrPassword = FirebaseAuthError(
    title: "メールアドレスまたはパスワードに誤りがあります",
    recoveryAction: nil
  )
}

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
