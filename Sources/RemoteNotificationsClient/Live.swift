import UserNotifications

extension RemoteNotificationsClient {
  private static var delegate: Delegate?

  public static let live = Self(
    delegate: { presentationOptions in
      AsyncStream { continuation in
        Self.delegate = Delegate(continuation: continuation, presentationOptions: presentationOptions)
        guard let delegate = Self.delegate else { return }
        UNUserNotificationCenter.current().delegate = delegate
      }
    },
    requestAuthorizations: { try await UNUserNotificationCenter.current().requestAuthorization(options: $0) }
  )
}

extension RemoteNotificationsClient {
  fileprivate class Delegate: NSObject, UNUserNotificationCenterDelegate {
    let continuation: AsyncStream<RemoteNotificationsClient.DelegateEvent>.Continuation
    let presentationOptions: UNNotificationPresentationOptions

    init(
      continuation: AsyncStream<RemoteNotificationsClient.DelegateEvent>.Continuation,
      presentationOptions: UNNotificationPresentationOptions
    ) {
      self.continuation = continuation
      self.presentationOptions = presentationOptions
    }

    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
      self.continuation.yield(.willPresentNotification(notification))
      return presentationOptions
    }

    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse
    ) async {
      self.continuation.yield(.didReceiveResponse(response))
    }
  }
}
