import Foundation

public struct LoadingError: LocalizedError, Equatable {
  public var errorDescription: String?
  public var failureReason: String?
  public var recoverySuggestion: String?
  public var recoveryAction: RecoveryAction?

  public init(
    errorDescription: String,
    failureReason: String? = nil,
    recoverySuggestion: String? = nil,
    recoveryAction: RecoveryAction? = nil
  ) {
    self.errorDescription = errorDescription
    self.failureReason = failureReason
    self.recoverySuggestion = recoverySuggestion
    self.recoveryAction = recoveryAction
  }

  public init(error: Error) {
    if let error = error as? LoadingError {
      self = error
    } else {
      self = LoadingError(errorDescription: error.localizedDescription)
    }
  }
}

public enum RecoveryAction {
  case login
  case openSettingApp
  case reload

  public var displayName: String {
    switch self {
    case .login: return "ログインする"
    case .openSettingApp: return "設定"
    case .reload: return "再読み込み"
    }
  }
}
