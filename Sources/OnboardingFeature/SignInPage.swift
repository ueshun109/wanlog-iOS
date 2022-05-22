import AuthenticationServices
import Core
import DataStore
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

/// ログインページ
public struct SignInPage<Router: Routing>: View where Router._Route == SignInRoute {
  private struct UIState {
    var email = ""
    var password = ""
    var loadingState: LoadingState = .idle
    var showAlert = false
    var showModal = false
    var pushTransitions = false
    var route: SignInRoute? {
      didSet {
        showModal = true
      }
    }
  }

  @EnvironmentObject private var userState: UserState
  @State private var uiState = UIState()

  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  public var body: some View {
    ZStack(alignment: .top) {
      VStack(spacing: Padding.large) {
        Group {
          VStack(spacing: Padding.medium) {
            InputForm(
              text: $uiState.email,
              placeholder: Strings.mailAddress.localized,
              keyboardType: .emailAddress
            )
            SecureForm(
              text: $uiState.password,
              placeholder: Strings.password.localized
            )
          }

          EnterButton(title: Strings.signIn.localized) {

          }
          .buttonStyle(EnterButtonStylePrimary(backgroundColor: Color.Blue.primary))

          HStack(spacing: Padding.small) {
            HorizontalBorder()
            Text("or")
              .fontWithLineHeight(font: .sfPro(.callout))
              .foregroundColor(Color.Label.secondary)
            HorizontalBorder()
          }

          SignInWithAppleButton(.signIn) { request in

          } onCompletion: { _ in

          }
          .frame(height: 44)

          Button {
            Task {
              await userState.anonymousSignin()
            }
          } label: {
            Text(Strings.skip.localized)
              .underline()
              .foregroundColor(Color.Label.secondary)
              .fontWithLineHeight(font: .hiraginoSans(.callout))
          }

          HStack {
            Image.infoCircle
            Text(Strings.signUpPros.localized)
              .fontWithLineHeight(font: .hiraginoSans(.footnote))
          }
          .foregroundColor(Color.Label.secondary)
        }
        .padding(.horizontal, Padding.medium)
      }
      .padding(.top, Padding.large)

      VStack(spacing: 0) {
        Spacer()

        HorizontalBorder()

        Button {
          
        } label: {
          Text("アカウントをお持ちでない場合 登録はこちら")
            .foregroundColor(Color.Blue.primary)
            .fontWithLineHeight(font: .hiraginoSans(.callout))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Padding.medium)
        .padding(.top, Padding.medium)
        .padding(.bottom, Padding.xxLarge)
        .background(Color.Blue.tertiary)
      }
    }
    .onReceive(userState.error) { error in
      uiState.loadingState = .failed(error: error)
      uiState.showAlert = true
    }
    .navigate(
      router: router,
      route: uiState.route,
      isActive: $uiState.pushTransitions,
      isPresented: $uiState.showModal,
      onDismiss: nil
    )
    .loading($uiState.loadingState, showAlert: $uiState.showAlert)
    .navigationTitle(Strings.signIn.localized)
    .ignoresSafeArea(.all, edges: .bottom)
  }
}
