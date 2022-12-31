import UIKit

extension RemoteNotificationsClient {
  public static let live = Self(
    register: { UIApplication.shared.registerForRemoteNotifications() }
  )
}
