import Combine
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
  @State private var route: DogRoute? = nil {
    didSet {
      switch route {
      case .create:
        uiState.showModal = true
      case .detail:
        uiState.pushTransition = true
      case .none:
        break
      }
    }
  }
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
      query: query
    ) { data in
      DogsSection(dogs: data) { route in
        self.route = route
      }
    } onFailure: { error in
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          route = .create
        } label: {
          Image.plusCircle
        }
      }
    }
    .navigate(
      router: router,
      route: route,
      isActive: $uiState.pushTransition,
      isPresented: $uiState.showModal,
      onDismiss: {}
    )
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      let db = Firestore.firestore()
      self.query = db.dogs(uid: uid)
    }
  }

  private struct DogsSection: View {
    let dogs: [Dog]
    let routing: (DogRoute?) -> Void

    @ViewBuilder
    var body: some View {
      if dogs.isEmpty {
        Text("ワンちゃんを迎い入れましょう")
      } else {
        List {
          ForEach(dogs) { dog in
            Button {
              routing(.detail(dog: dog))
            } label: {
              DogItem(dog: dog)
            }
          }
        }
      }
    }
  }

  private struct DogItem: View {
    @State var image: UIImage?

    let storage: Storage = .storage()
    let dog: Dog
    var body: some View {
      HStack {
        if let image = image {
          Image(uiImage: image)
            .resizable()
            .frame(width: 32, height: 32)
            .scaledToFit()
            .clipShape(Circle())
        } else {
          Image.person
        }

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
      .task {
        if let refString = dog.iconRef {
          do {
            let data = try await storage.reference(withPath: refString).get()
            image = UIImage(data: data)
          } catch {
            // TODO: エラーハンドリング
          }
        }
      }
    }
  }
}

func toString(_ date: Date, formatter: DateFormatter) -> String {
  formatter.string(from: date)
}
