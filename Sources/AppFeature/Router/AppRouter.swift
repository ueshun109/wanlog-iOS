import OnboardingFeature
import Core
import SwiftUI

public class AppRouter: Routing {
  public init() {}

  @ViewBuilder
  public func view(for route: AppRoute) -> some View {
    switch route {
    case .authentication:
      SignInPage(router: SignInRouter())
    case .home:
      Text("TODO: Home")
    case .onboarding:
      Text("TODO: Onboarding")
    }
  }

  public func route(from deeplink: URL) -> AppRoute? {
    nil
  }
}
