import Core
import Styleguide
import SwiftUI

public struct DogsListPage<Router: Routing>: View where Router._Route == DogRoute {
  private struct UiState {
    var showModal = false
  }
  @State private var route: DogRoute? = nil {
    didSet {
      switch route {
      case .create:
        uiState.showModal = true
      case .none:
        break
      }
    }
  }
  @State private var uiState = UiState()
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  public var body: some View {
    VStack {

    }
    .navigate(
      router: router,
      route: route,
      isActive: .constant(false),
      isPresented: $uiState.showModal,
      onDismiss: nil
    )
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          route = .create
        } label: {
          Image.plusCircle
        }
      }
    }
  }
}
