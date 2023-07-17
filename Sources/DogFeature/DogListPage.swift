import Combine
import Core
import FirebaseClient
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct DogsListPage<Router: Routing>: View where Router._Route == DogRoute {
  @State private var query: FirebaseFirestore.Query?
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: Dog.skelton,
      query: query,
      onSuccess: list(dogs:)
    ) { error in
    }
    .toolbar(content: toolbarItems)
    .navigate(
      router: router,
      route: uiState.route,
      isActive: $uiState.pushTransition,
      isPresented: $uiState.showModal,
      onDismiss: {}
    )
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      let query: Query.Dog = .all(uid: uid)
      self.query = query.collection()
    }
  }

  @ViewBuilder
  /// 📖 View to display a list of Dog.
  func list(dogs: [Dog]) -> some View {
    if dogs.isEmpty {
      // TODO: 画像付きのEmptyViewに差し替える
      Text("ワンちゃんを迎え入れましょう")
    } else {
      List {
        ForEach(dogs) { dog in
          Button {
            uiState.route = .detail(dog: dog)
          } label: {
            dogItem(dog: dog)
          }
          .padding(.vertical, Padding.xxSmall)
        }
      }
    }
  }

  /// 🐶 List item for Dog.
  func dogItem(dog: Dog) -> some View {
    Label {
      Text(dog.name)
        .font(.headline)
    } icon: {
      FIRStorageImage(reference: dog.iconRef) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(width: 32, height: 32)
          .clipShape(Circle())
      } placeholder: {
        Image.person
      }
    }
  }

  @ToolbarContentBuilder
  /// 🧰 Toolbar items
  func toolbarItems() -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        uiState.route = .createFirst {
          uiState.showModal = false
        }
      } label: {
        Image.plusCircle
      }
    }
  }
}

// MARK: - UiState

extension DogsListPage {
  struct UiState {
    var pushTransition = false
    var showModal = false

    var route: DogRoute? = nil {
      didSet {
        switch route {
        case .createFirst:
          showModal = true
        case .detail:
          pushTransition = true
        case .none:
          break
        }
      }
    }
  }
}
