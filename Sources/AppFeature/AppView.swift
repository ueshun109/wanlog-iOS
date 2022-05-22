import Core
import DataStore
import OnboardingFeature
import SwiftUI
import UserNotificationClient

public struct AppView<Router: Routing>: View where Router._Route == AppRoute {
  private let router: Router
  @StateObject private var userState: UserState

  public init(userNotifications: UserNotificationClient, router: Router) {
    self._userState = .init(wrappedValue: .init(authenticator: .live))
    self.router = router
  }

  public var body: some View {
    ZStack {
      NavigationView {
        if userState.isSignIn {
          router.view(for: .home)
        } else {
          router.view(for: .authentication)
        }
      }
    }
    .environmentObject(userState)
    .task {
      await userState.confirmAuthStatus()
    }
  }
}
