import Foundation

/// ロードエラー
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
}

/// エラーが発生した際にユーザーに行ってもらうアクションの一覧
public enum RecoveryAction {
  /// ログイン
  case login
  /// 設定アプリを開く
  case openSettingApp
  /// 再読み込み
  case reload
}
