import Core
import FirebaseClient
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct DogsListPage<Router: Routing>: View where Router._Route == DogRoute {
  private struct UiState {
    var showModal = false
    var pushTransition = false
  }
  @State private var route: DogRoute? = nil
  @State private var query: Query?
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: Dog.skelton,
      query: query
    ) { data in
      DogsSection(dogs: data, route: $route)
    } onFailure: { error in

    }
    .navigate(
      router: router,
      route: route,
      isActive: $uiState.pushTransition,
      isPresented: $uiState.showModal,
      onDismiss: {
        route = nil
      }
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
    .onChange(of: route) { new in
      switch new {
      case .create:
        uiState.showModal = true
      case .detail:
        uiState.pushTransition = true
      case .none:
        break
      }
    }
    .onAppear {
      route = nil
    }
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      let db = Firestore.firestore()
      self.query = db.dogs(uid: uid)
    }
  }

  private struct DogsSection: View {
    let dogs: [Dog]
    @Binding var route: DogRoute?

    @ViewBuilder
    var body: some View {
      if dogs.isEmpty {
        Text("ワンちゃんを迎い入れましょう")
      } else {
        List {
          ForEach(dogs) { dog in
            Button {
              route = .detail(dog: dog)
            } label: {
              DogItem(dog: dog)
            }
          }
        }
      }
    }
  }

  private struct DogItem: View {
    let dog: Dog
    var body: some View {
      HStack {
        Image.person

        VStack(alignment: .leading) {
          Text(dog.name)
            .font(.headline)

          Text(toString(
            dog.birthDate.dateValue(),
            formatter: .yearAndMonthAndDayWithSlash
          ))
          .font(.subheadline)
        }

        Spacer()
      }
    }
  }
}

func toString(_ date: Date, formatter: DateFormatter) -> String {
  formatter.string(from: date)
}
