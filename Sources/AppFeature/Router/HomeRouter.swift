import CertifiateFeature
import Core
import DogFeature
import HomeFeature
import SwiftUI
import TaskFeature

struct HomeRouter: Routing {
  @ViewBuilder
  func view(for route: HomeRoute) -> some View {
    switch route {
    case .taskList(let query):
      let taskRouter = TaskRouter()
      let page = TaskListPage(
        normalTaskQuery: query,
        router: taskRouter
      )
      page
    case .dogList:
      DogsListPage(router: DogRouter())
    case .history(let query):
      CertificateListPage(query: query, router: CertificateRouter())
    }
  }
}

struct TaskRouter: Routing {
  @ViewBuilder
  func view(for route: TaskRoute) -> some View {
    switch route {
    case .create:
      CreateTaskPage()
    case .detail(let task):
      UpdateTaskPage(task: task)
    }
  }
}
