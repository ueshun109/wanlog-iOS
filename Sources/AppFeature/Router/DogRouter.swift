import Core
import DogFeature
import ScheduleFeature
import SwiftUI

struct DogRouter: Routing {
  @ViewBuilder
  func view(for route: DogRoute) -> some View {
    switch route {
    case .create:
      CreateDogPage()
    case .detail(let dog):
      DogDetailPage(dog: dog, router: DogDetailRouter())
    }
  }
}

struct DogDetailRouter: Routing {
  @ViewBuilder
  func view(for route: DogDetailRoute) -> some View {
    switch route {
    case .schedules(let query):
      SchedulePage(query: query, router: ScheduleRouter())
    }
  }
}
