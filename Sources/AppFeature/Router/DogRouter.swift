import Core
import DogFeature
import SwiftUI
import TaskFeature

struct DogRouter: Routing {
  @ViewBuilder
  func view(for route: DogRoute) -> some View {
    switch route {
    case .createFirst(let dismiss):
      DogCreateFirstPage(router: DogCreateRouter(), dismiss: dismiss)
    case .detail(let dog):
      DogDetailPage(dog: dog, router: DogDetailRouter())
    }
  }
}

struct DogCreateRouter: Routing {
  @ViewBuilder
  func view(for route: DogCreateRoute) -> some View {
    switch route {
    case .createSecond(let dogState):
      DogCreateSecondPage(dog: dogState)
    }
  }
}

struct DogDetailRouter: Routing {
  @ViewBuilder
  func view(for route: DogDetailRoute) -> some View {
    switch route {
    case .tasks(let query):
      TodoListPage(todoQuery: query, router: TodoRouter())
    }
  }
}
