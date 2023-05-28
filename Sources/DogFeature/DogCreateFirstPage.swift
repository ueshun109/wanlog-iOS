import Core
import FirebaseClient
import Styleguide
import SwiftUI
import SharedComponents
import SharedModels

public struct DogCreateFirstPage<Router: Routing>: View where Router._Route == DogCreateRoute {
  @Environment(\.dismiss) var dismiss
  @State private var image: UIImage?
  @State private var uiState = UiState()
  @StateObject private var dog = DogState()

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()
  private let router: Router

  public init(router: Router) {
    self.router = router
  }

  public var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: Padding.medium) {
          iconSection
          nameSection
          birthDateSection
          biologicalSexSection
        }
        .padding(.horizontal, Padding.medium)
      }
      .background(Color.Background.primary)
      .onChange(of: uiState.action) { new in
        guard let new else { return }
        run(action: new)
      }
      .navigate(
        router: router,
        route: uiState.route,
        isActive: $uiState.pushTransition,
        isPresented: .constant(false),
        onDismiss: nil
      )
      .confirmationDialog(
        "",
        isPresented: $uiState.showConfirmationDialog,
        titleVisibility: .hidden,
        actions: actionButtons
      )
      .sheet(isPresented: $uiState.showCamera) {
        CameraView(image: $image)
      }
      .sheet(isPresented: $uiState.showPhotoLibrary) {
        PhotoLibraryView(image: $image)
      }
      .loading($uiState.loading, showAlert: $uiState.showAlert)
      .navigationTitle("ワンちゃん迎い入れ 1/2")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: toolbarItems)
    }
  }

  /// 🐶 Dog icon section
  var iconSection: some View {
    Section {
      Icon(image: image, placeholder: Image.person)
        .onTapGesture {
          uiState.showConfirmationDialog.toggle()
        }
    }
  }

  /// 🏷️ Name section
  var nameSection: some View {
    Section {
      InputForm(title: "名前", text: $dog.name, maxLength: 10)
    } header: {
      sectionHeader(title: "名前", other: "\(dog.name.count)/10")
        .padding(.bottom, -Padding.small)
    }
  }

  /// 🎂 Birth date section
  var birthDateSection: some View {
    Section {
      DateForm(date: $dog.bitrhDate)
    } header: {
      sectionHeader(title: "誕生日")
        .padding(.bottom, -Padding.small)
    }
  }

  /// ♂♀ Biological sex section
  var biologicalSexSection: some View {
    Section {
      PickerForm(
        item: $dog.biologicalSex,
        items: BiologicalSex.allCases,
        keyPath: \.title,
        title: "性別",
        style: .segmented
      )
    } header: {
      sectionHeader(title: "性別")
        .padding(.bottom, -Padding.small)
    }
  }

  @ViewBuilder
  /// 🟢 Buttons for action sheet
  func actionButtons() -> some View {
    Button {
      uiState.showCamera = true
    } label: {
      Text("写真を撮る")
    }

    Button {
      uiState.showPhotoLibrary = true
    } label: {
      Text("写真を選択")
    }
  }

  /// ⛑️ Section header
  func sectionHeader(title: String, other: String? = nil) -> some View {
    HStack {
      Text(title)
      Spacer()
      if let other {
        Text(other)
      }
    }
    .font(.footnote)
    .foregroundColor(Color.Label.secondary)
    .padding(.horizontal, Padding.small)
  }

  @ToolbarContentBuilder
  /// 🧰 Toolbar items
  func toolbarItems() -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button {
        dismiss()
      } label: {
        Text("キャンセル")
      }
    }

    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        uiState.route = .createSecond(state: dog)
      } label: {
        Text("次へ")
      }
      .disabled(dog.name.isEmpty || image == nil)
    }
  }
}

// MARK: - State

public class DogState: ObservableObject {
  @Published var biologicalSex: BiologicalSex = .male
  @Published var bitrhDate: Date = .init()
  @Published var name: String = ""
  @Published var combinationVaccineFrequency: CombinationVaccineFrequency?
  @Published var combinationVaccineDate: Date = .now
  @Published var filariasisDosingDate: Date = .now
  @Published var rabiesVaccineDate: Date = .now

  func create() -> Dog {
    Dog(
      name: name,
      birthDate: .init(date: bitrhDate),
      biologicalSex: biologicalSex
    )
  }
}

extension DogCreateFirstPage {
  struct UiState {
    var action: Action?
    var loading: Loading = .idle
    var pushTransition: Bool = false
    var showAlert: Bool = false
    var showCamera = false
    var showConfirmationDialog = false
    var showPhotoLibrary = false
    var route: DogCreateRoute? = nil {
      didSet {
        switch route {
        case .createSecond:
          pushTransition = true
        case .none:
          break
        }
      }
    }
  }
}

// MARK: - Action

extension DogCreateFirstPage {
  enum Action: Equatable {
    case tappedSaveButton
  }

  func run(action: Action) {
    switch action {
    case .tappedSaveButton:
      Task {
        defer {
          uiState.action = nil
        }
        guard let uid = await authenticator.user()?.uid else { return }
        uiState.loading = .loading
        let query: Query.Dog = .all(uid: uid)
        var newDog = dog.create()
        do {
          let docRef = try await db.set(newDog, collectionReference: query.collection())
          let dogId = docRef.documentID
          let storageRef = Storage.storage().dogRef(uid: uid, dogId: dogId)
          guard let image = image else {
            uiState.loading = .loaded
            dismiss()
            return
          }
          let oneMB = 1024 * 1024
          if image.exceed(oneMB) {
            let data = image.resize(to: oneMB)
            try await storageRef.upload(data)
          } else if let data = image.pngData() {
            try await storageRef.upload(data)
          }
          newDog.iconRef = storageRef.fullPath
          try await db.set(newDog, documentReference: docRef)
          uiState.loading = .loaded
          dismiss()
        } catch let loadingError as LoadingError {
          uiState.loading = .failed(error: loadingError)
        }
      }
    }
  }
}

struct DogCreatePage_Previews: PreviewProvider {
  struct MockRouter: Routing {
    func view(for route: DogCreateRoute) -> some View {
      EmptyView()
    }
  }
  static let router = MockRouter()
  static var previews: some View {
    DogCreateFirstPage(router: router)
  }
}
