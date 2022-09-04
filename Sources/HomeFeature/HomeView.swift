import FirebaseClient
import Styleguide
import SwiftUI
import Core

public struct HomeView<Router: Routing>: View where Router._Route == HomeRoute {
  @State private var uid: String?
  @State private var query: Query?

  private let authenticator: Authenticator = .live
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  private enum Tag {
    case schedule
    case dogList
    case history
  }

  public var body: some View {
    TabView {
      NavigationView {
        if let query = query {
          router.view(for: .schedule(query))
            .navigationTitle(Text("予定"))
        } else {
          EmptyView()
        }
      }
      .tabItem {
        Image.calendar
        Text("ホーム")
      }
      .tag(Tag.schedule)

      NavigationView {
        router.view(for: .dogList)
          .navigationTitle(Text("ワンちゃん一覧"))
      }
      .tabItem {
        Image.listDash
        Text("わんちゃん")
      }
      .tag(Tag.dogList)

      router.view(for: .history)
        .tabItem {
          Image.booksVertical
          Text("接種履歴")
        }
        .tag(Tag.history)
    }
    .task {
      self.uid = await authenticator.user()?.uid ?? ""
      self.query = Query.schedules(uid: uid!, incompletedOnly: true)
    }
  }
}
