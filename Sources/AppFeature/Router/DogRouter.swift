import Core
import DogFeature
import SwiftUI
import TaskFeature

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
    case .tasks(let query):
      TaskListPage(normalTaskQuery: query, router: TaskRouter())
    }
  }
}
