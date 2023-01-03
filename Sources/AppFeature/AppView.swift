import Core
import DataStore
import FirebaseMessaging
import OnboardingFeature
import SharedModels
import SwiftUI
import UserNotificationClient
import RemoteNotificationsClient

public struct AppView<Router: Routing>: View where Router._Route == AppRoute {
  private let router: Router
  @StateObject private var userState: UserState
  let client: RemoteNotificationsClient = .live

  public init(userNotifications: UserNotificationClient, router: Router) {
    self._userState = .init(wrappedValue: .init(authenticator: .live))
    self.router = router
  }

  public var body: some View {
    ZStack {
      if userState.isSignIn {
        router.view(for: .home)
      } else {
        router.view(for: .authentication)
      }
    }
    .environmentObject(userState)
    .onChange(of: userState.isSignIn) { signin in
      guard signin else { return }
      Task {
        guard let uid = await userState.currentUser()?.uid,
              let deviceToken = try? await Messaging.messaging().token()
        else { return }
        let owner = Owner(deviceToken: deviceToken)
        let query: Query.Owner = .one(uid: uid)
        try? await Firestore.firestore().set(owner, documentReference: query.document())
      }
    }
    .task {
      await userState.confirmAuthStatus()
      _ = try? await client.requestAuthorizations([.alert, .badge, .sound, .provisional])
      for await event in client.delegate([.sound, .banner, .list, .badge]) {
        switch event {
        case .didReceiveResponse(let response):
          let userInfo = response.notification.request.content.userInfo
          Messaging.messaging().appDidReceiveMessage(userInfo)
        case .willPresentNotification(let notification):
          let userInfo = notification.request.content.userInfo
          Messaging.messaging().appDidReceiveMessage(userInfo)
        }
      }
    }
  }
}
