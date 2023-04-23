import FirebaseClient
import Styleguide
import SwiftUI
import Core

public struct HomeView<Router: Routing>: View where Router._Route == HomeRoute {
  @State private var uid: String?
  @State private var certificateQuery: Query.Certificate?
  @State private var todoQuery: Query.Todo?

  private let authenticator: Authenticator = .live
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  private enum Tag {
    case taskList
    case dogList
    case history
  }

  public var body: some View {
    TabView {
      NavigationView {
        if let query = todoQuery {
          router.view(for: .taskList(query))
            .navigationTitle(Text("予定"))
        } else {
          EmptyView()
        }
      }
      .tabItem {
        Image.calendar
        Text("ホーム")
      }
      .tag(Tag.taskList)

      NavigationView {
        router.view(for: .dogList)
          .navigationTitle(Text("ワンちゃん一覧"))
      }
      .tabItem {
        Image.listDash
        Text("わんちゃん")
      }
      .tag(Tag.dogList)

      NavigationView {
        if let query = certificateQuery {
          router.view(for: .history(query))
            .navigationTitle(Text("接種履歴一覧"))
        } else {
          EmptyView()
        }
      }
      .tabItem {
        Image.booksVertical
        Text("接種履歴")
      }
      .tag(Tag.history)


    }
    .task {
      self.uid = await authenticator.user()?.uid ?? ""
      self.todoQuery = .all(uid: uid!)
      self.certificateQuery = .all(uid: uid!)
    }
  }
}
