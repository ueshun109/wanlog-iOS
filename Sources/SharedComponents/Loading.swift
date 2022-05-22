import SharedModels
import SwiftUI

/// ロード中はローディングインジケータを表示し、ロード失敗時はアラートを表示するModifier
public struct LoadingModifier: ViewModifier {
  @Binding private var showAlert: Bool
  @Binding private var state: LoadingState
  private let recoverAction: (() -> Void)?
  private let destructiveAction: (() -> Void)?

  public init(
    state: Binding<LoadingState>,
    showAlert: Binding<Bool>,
    recoverAction: (() -> Void)?,
    destructiveAction: (() -> Void)?
  ) {
    self._state = state
    self._showAlert = showAlert
    self.recoverAction = recoverAction
    self.destructiveAction = destructiveAction
  }

  public func body(content: Content) -> some View {
    switch state {
    case .idle, .loaded:
      content
    case .loading:
      ZStack {
        content
        ProgressView()
      }
    case .failed(let error):
      if #available(iOS 15, *) {
        content
          .alert(error.localizedDescription, isPresented: $showAlert) {
            if let label = error.recoverySuggestion, let recoverAction = recoverAction {
              Button(label, action: recoverAction)

              Button("キャンセル", role: .cancel, action: {})
            }

            if let label = error.recoverySuggestion, let destructiveAction = destructiveAction {
              Button(label, role: .destructive, action: destructiveAction)
            }
          } message: {
            Text(error.failureReason ?? "")
          }
      } else {
        switch (recoverAction, destructiveAction) {
        case (.none, .some(let destructive)):
          content
            .alert(isPresented: $showAlert) {
              Alert(
                title: Text(error.localizedDescription),
                message: Text(error.failureReason ?? ""),
                primaryButton: .destructive(Text(error.recoverySuggestion ?? ""), action: destructive),
                secondaryButton: .cancel(Text("キャンセル"))
              )
            }
        case (.some(let recover), .none):
          content
            .alert(isPresented: $showAlert) {
              Alert(
                title: Text(error.localizedDescription),
                message: Text(error.failureReason ?? ""),
                primaryButton: .default(Text(error.recoverySuggestion ?? ""), action: recover),
                secondaryButton: .cancel(Text("キャンセル"))
              )
            }
        default:
          content
            .alert(isPresented: $showAlert) {
              Alert(
                title: Text(error.localizedDescription),
                message: Text(error.failureReason ?? "")
              )
            }
        }
      }
    }
  }
}

public extension View {
  /// ローディング状態に応じた`View`が表示されるようにします。
  /// - Parameters:
  ///   - state: ローディング状態
  ///   - showAlert: アラートを表示するかどうかを決定するプロパティへのバインディング
  /// - Returns: `View`
  func loading(
    _ state: Binding<LoadingState>,
    showAlert: Binding<Bool>,
    recover: (() -> Void)? = nil,
    destructive: (() -> Void)? = nil
  ) -> some View {
    self.modifier(
      LoadingModifier(
        state: state,
        showAlert: showAlert,
        recoverAction: recover,
        destructiveAction: destructive
      )
    )
  }
}
