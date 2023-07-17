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
