import OnboardingFeature
import Core
import SwiftUI
import HomeFeature

public class AppRouter: Routing {
  public init() {}

  @ViewBuilder
  public func view(for route: AppRoute) -> some View {
    switch route {
    case .authentication:
      NavigationView {
        SignInPage(router: SignInRouter())
          .navigationTitle(Text("ログイン"))
      }
    case .home:
      HomeView(router: HomeRouter())
    case .onboarding:
      Text("TODO: Onboarding")
    }
  }

  public func route(from deeplink: URL) -> AppRoute? {
    nil
  }
}
