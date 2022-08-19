import Styleguide
import SwiftUI
import Core

public struct HomeView<Router: Routing>: View where Router._Route == HomeRoute {
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  public var body: some View {
    TabView {
      NavigationView {
        router.view(for: .schedule)
          .navigationTitle(Text("予定"))
      }
      .tabItem {
        Image.calendar
        Text("ホーム")
      }
      .tag(HomeRoute.schedule)

      NavigationView {
        router.view(for: .dogList)
          .navigationTitle(Text("ワンちゃん一覧"))
      }
      .tabItem {
        Image.listDash
        Text("わんちゃん")
      }
      .tag(HomeRoute.dogList)

      router.view(for: .history)
        .tabItem {
          Image.booksVertical
          Text("接種履歴")
        }
        .tag(HomeRoute.history)
    }
  }
}
