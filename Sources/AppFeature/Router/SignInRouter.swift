import Core
import SwiftUI
import OnboardingFeature

public class SignInRouter: Routing {
  public init() {}

  @ViewBuilder
  public func view(for route: SignInRoute) -> some View {
    switch route {
    case .signUp:
      Text("SignUp")
    case .home:
      Text("Home")
    }
  }

  public func route(from deeplink: URL) -> SignInRoute? {
    nil
  }
}
