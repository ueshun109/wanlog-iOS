import SwiftUI
import UserNotifications

public struct RemoteNotificationsClient {
  public var delegate: @Sendable (UNNotificationPresentationOptions) -> AsyncStream<DelegateEvent>
  public var requestAuthorizations: (UNAuthorizationOptions) async throws -> Bool

  public enum DelegateEvent {
    case didReceiveResponse(UNNotificationResponse)
    case willPresentNotification(UNNotification)
  }
}

