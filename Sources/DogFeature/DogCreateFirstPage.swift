import Core
import FirebaseClient
import Styleguide
import SwiftUI
import SharedComponents
import SharedModels

public struct DogCreateFirstPage<Router: Routing>: View where Router._Route == DogCreateRoute {
  @State private var uiState = UiState()
  @StateObject private var dog = DogCreateFlow()

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()
  private let router: Router
  private let dismiss: (() -> Void)?

  public init(router: Router, dismiss: (() -> Void)? = nil) {
    self.router = router
    self.dismiss = dismiss
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
      .navigate(
        router: router,
        route: uiState.route,
        isActive: $uiState.pushTransition,
        isPresented: .constant(false),
        onDismiss: nil
      )
      .onChange(of: dog.dismiss) { new in
        if new { dismiss?() }
      }
      .confirmationDialog(
        "",
        isPresented: $uiState.showConfirmationDialog,
        titleVisibility: .hidden,
        actions: actionButtons
      )
      .sheet(isPresented: $uiState.showCamera) {
        CameraView(image: $dog.image)
      }
      .sheet(isPresented: $uiState.showPhotoLibrary) {
        PhotoLibraryView(image: $dog.image)
      }
      .loading($uiState.loading, showAlert: $uiState.showAlert)
      .navigationTitle("ワンちゃん迎え入れ 1/2")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: toolbarItems)
    }
  }

  /// 🐶 Dog icon section
  var iconSection: some View {
    Section {
      Group {
        if let image = dog.image {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        } else {
          ZStack {
            Image.person
              .resizable()
              .frame(width: 60, height: 60)
          }
          .background(
            Circle()
              .fill(Color.Background.secondary)
              .frame(width: 100, height: 100)
          )
        }
      }
      .frame(width: 100, height: 100)
      .clipShape(Circle())
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
        items: Dog.BiologicalSex.allCases,
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
        dog.dismiss = true
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
      .disabled(dog.name.isEmpty || dog.image == nil)
    }
  }
}

// MARK: - State

public class DogCreateFlow: ObservableObject {
  @Published var biologicalSex: Dog.BiologicalSex = .male
  @Published var bitrhDate: Date = .init()
  @Published var name: String = ""
  @Published var numberOfCombinationVaccine: Dog.Preventions.CombinationVaccine.NumberOfTimes?
  @Published var combinationVaccineDate: Date = .now
  @Published var filariasisDosingDate: Date = .now
  @Published var rabiesVaccineDate: Date = .now
  @Published var image: UIImage?
  @Published var dismiss: Bool = false

  func create(
    hasBeenVaccinatedWithCombinationVaccine: Bool,
    hasBeenVaccinatedWithRabiesVaccine: Bool,
    hasTakenHeartwormPill: Bool
  ) -> Dog {
    let combinationVaccine: Dog.Preventions.CombinationVaccine = .init(
      latestDate: hasBeenVaccinatedWithCombinationVaccine ? combinationVaccineDate : nil,
      number: numberOfCombinationVaccine
    )
    let heartwormPill: Dog.Preventions.HeartwormPill = .init(
      latestDate: hasTakenHeartwormPill ? filariasisDosingDate : nil
    )
    let rabiesVaccine: Dog.Preventions.RabiesVaccine = .init(
      latestDate: hasBeenVaccinatedWithRabiesVaccine ? rabiesVaccineDate : nil
    )

    return Dog(
      name: name,
      birthDate: .init(date: bitrhDate),
      biologicalSex: biologicalSex,
      preventions: .init(
        combinationVaccine: combinationVaccine,
        heartwormPill: heartwormPill,
        rabiesVaccine: rabiesVaccine
      )
    )
  }
}

// MARK: - UiState

extension DogCreateFirstPage {
  struct UiState {
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
