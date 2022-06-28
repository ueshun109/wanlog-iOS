import FirebaseFirestore

public struct FirestoreError {
  public let title: String
  public let description: String?
  public let recoveryAction: RecoveryAction?
}

public extension FirestoreError {
  static let unknown = FirestoreError(
    title: "不明なエラーが発生しました",
    description: "時間を置いて再度アクセスしてください。",
    recoveryAction: .reload
  )

  static let badRequest = FirestoreError(
    title: "リクエスト内容に誤りがあります",
    description: "リクエスト内容を確認してください。",
    recoveryAction: nil
  )

  static let timeout = FirestoreError(
    title: "タイムアウト",
    description: "処理に時間がかかりすぎています。電波状況など確認し、再度アクセスしてください。",
    recoveryAction: .reload
  )

  static let notFound = FirestoreError(
    title: "データが見つかりませんでした",
    description: nil,
    recoveryAction: nil
  )

  static let alreadyExists = FirestoreError(
    title: "既に登録されています",
    description: nil,
    recoveryAction: nil
  )

  static let notAuthorized = FirestoreError(
    title: "アクセス権限がありません",
    description: "ログインしてください。",
    recoveryAction: .login
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
