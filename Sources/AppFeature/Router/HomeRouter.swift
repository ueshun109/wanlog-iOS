import CertifiateFeature
import Core
import DogFeature
import HomeFeature
import ScheduleFeature
import SwiftUI

struct HomeRouter: Routing {
  @ViewBuilder
  func view(for route: HomeRoute) -> some View {
    switch route {
    case .schedule(let query):
      let scheduleRouter = ScheduleRouter()
      let page = SchedulePage(
        scheduleQuery: query,
        router: scheduleRouter
      )
      page
    case .dogList:
      DogsListPage(router: DogRouter())
    case .history(let query):
      CertificateListPage(query: query, router: CertificateRouter())
    }
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
