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
      let todoRouter = TodoRouter()
      let page = TodoListPage(todoQuery: query, router: todoRouter)
      page
    case .dogList:
      DogsListPage(router: DogRouter())
    case .history(let query):
      CertificateListPage(query: query, router: CertificateRouter())
    }
  }
}

struct TodoRouter: Routing {
  @ViewBuilder
  func view(for route: TodoRoute) -> some View {
    switch route {
    case .create:
      TodoCreatePage()
    case .detail(let todo):
      TodoUpdatePage(todo: todo)
    }
  }
}
