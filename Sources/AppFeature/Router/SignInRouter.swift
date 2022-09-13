import Core
import SwiftUI
import OnboardingFeature

struct SignInRouter: Routing {
  @ViewBuilder
  func view(for route: SignInRoute) -> some View {
    switch route {
    case .signUp:
      Text("SignUp")
    case .home:
      Text("Home")
    }
  }
}
