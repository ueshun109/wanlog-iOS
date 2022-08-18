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
      SchedulePage(router: ScheduleRouter())
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

struct ScheduleRouter: Routing {
  @ViewBuilder
  func view(for route: ScheduleRoute) -> some View {
    switch route {
    case .create:
      CreateSchedulePage()
    case .detail(let schedule):
      UpdateSchedulePage(schedule: schedule)
    }
  }
}
