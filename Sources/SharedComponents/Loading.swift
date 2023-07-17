import SharedModels
import SwiftUI

/// ロード中はローディングインジケータを表示し、ロード失敗時はアラートを表示するModifier
public struct LoadingModifier: ViewModifier {
  @Binding private var showAlert: Bool
  @Binding private var state: Loading
  private let recoverAction: (() -> Void)?
  private let destructiveAction: (() -> Void)?

  public init(
    state: Binding<Loading>,
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
      .overlay(Color.black.opacity(0.4))
    case .failed(let error):
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
    _ state: Binding<Loading>,
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

