import Core
import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct DogDetailPage<Router: Routing>: View where Router._Route == DogDetailRoute {
  private struct UiState {
    var biologicalSex: BiologicalSex = .male
    var birthDate: Date = .init()
    var loading: Loading = .idle
    var name: String = ""
    var pushTransition = false
    var showAlert = false
    var showCamera = false
  }
  @State private var image: UIImage?
  @State private var uid: String = ""
  @State private var uiState = UiState()
  @State private var route: DogDetailRoute? = nil {
    didSet {
      switch route {
      case .tasks:
        uiState.pushTransition = true
      case .none:
        break
      }
    }
  }

  private let authenticator: Authenticator = .live
  private let dog: Dog
  private let router: Router
  private let storage: Storage = .storage()

  public init(dog: Dog, router: Router) {
    self.dog = dog
    self.router = router
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: Padding.large) {
        VStack(spacing: Padding.xSmall) {
          header(image: image)
            .onTapGesture {
              uiState.showCamera.toggle()
            }

          NameSection(name: $uiState.name)

          BirthDateSection(birthDate: $uiState.birthDate)

          BiologicalSexSection(biologicalSex: $uiState.biologicalSex)
        }

        VStack(spacing: Padding.small) {
          TaskSection() {
            route = .tasks(Query.Todo.perDog(uid: uid, dogId: dog.id!))
          }

          Divider()
            .padding(.trailing, -Padding.xSmall)

          HistorySection()
        }
        .foregroundColor(Color.Label.primary)
        .padding(Padding.small)
        .background(Color.Background.secondary)
        .clipShape(
          RoundedRectangle(cornerRadius: 8)
        )
      }
      .padding(.horizontal, Padding.medium)
    }
    .background(Color.Background.primary)
    .sheet(isPresented: $uiState.showCamera) {
      CameraView(image: $image)
    }
    .navigate(
      router: router,
      route: route,
      isActive: $uiState.pushTransition,
      isPresented: .constant(false),
      onDismiss: nil
    )
    .onAppear {
      uiState.biologicalSex = dog.biologicalSex
      uiState.birthDate = dog.birthDate.dateValue()
      uiState.name = dog.name
    }
    .task {
      self.uid = await authenticator.user()?.uid ?? ""

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

  private struct TaskSection: View {
    let onTap: () -> Void

    var body: some View {
      Button {
        onTap()
      } label: {
        HStack {
          Text("予定一覧")

          Spacer()

          Image.chevronForward
        }
      }
    }
  }

  private struct HistorySection: View {
    var body: some View {
      NavigationLink {

      } label: {
        HStack {
          Text("証明書一覧")

          Spacer()

          Image.chevronForward
        }
      }
    }
  }
}
