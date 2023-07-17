public struct CloudStorageError {
  public let title: String
  public let description: String?
  public let recoveryAction: RecoveryAction?
}

public extension CloudStorageError {
  static let notFound = CloudStorageError(
    title: "画像が見つかりませんでいした",
    description: nil,
    recoveryAction: nil
  )

  static let unauthorized = CloudStorageError(
    title: "アクセス権限がありません",
    description: nil,
    recoveryAction: nil
  )

  static let unknown = CloudStorageError(
    title: "不明なエラーが発生しました",
    description: nil,
    recoveryAction: nil
  )

  static let limitExceeded = CloudStorageError(
    title: "アクセスが多すぎます",
    description: "時間を置いて、再度アクセスしてください。",
    recoveryAction: nil
  )

  var toLoadingError: LoadingError {
    LoadingError(
      errorDescription: title,
      failureReason: description,
      recoverySuggestion: recoveryAction?.displayName,
      recoveryAction: recoveryAction
    )
  }
}
