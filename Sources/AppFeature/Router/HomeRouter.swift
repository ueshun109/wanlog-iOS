import Core
import HomeFeature
import ScheduleFeature
import SwiftUI

public class HomeRouter: Routing {
  public init() {}

  @ViewBuilder
  public func view(for route: HomeRoute) -> some View {
    switch route {
    case .schedule:
      SchedulePage()
    case .dogList:
      Text("DogList")
    case .history:
      Text("history")
    }
  }

  public func route(from deeplink: URL) -> HomeRoute? {
    nil
  }
}
