import FirebaseClient
import Styleguide
import SwiftUI
import SharedComponents
import SharedModels

public struct CreateDogPage: View {
  private struct UiState {
    var biologicalSex: BiologicalSex = .male
    var bitrhDate: Date = .init()
    var loading: Loading = .idle
    var name: String = ""
    var showAlert: Bool = false
    var showCamera = false
    var showConfirmationDialog = false
    var showPhotoLibrary = false
  }

  @Environment(\.dismiss) var dismiss
  @State private var image: UIImage?
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()

  public init() {}

  public var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: Padding.xSmall) {
          HeaderSection(image: image)
            .onTapGesture {
              uiState.showConfirmationDialog.toggle()
            }

          NameSection(name: $uiState.name)

          BirthDateSection(birthDate: $uiState.bitrhDate)

          BiologicalSexSection(biologicalSex: $uiState.biologicalSex)
        }
        .padding(.horizontal, Padding.medium)
      }
      .background(Color.Background.primary)
      .navigationTitle("ワンちゃん迎い入れ")
      .navigationBarTitleDisplayMode(.inline)
      .confirmationDialog(
        "",
        isPresented: $uiState.showConfirmationDialog,
        titleVisibility: .hidden
      ) {
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
      .sheet(isPresented: $uiState.showCamera) {
        CameraView(image: $image)
      }
      .sheet(isPresented: $uiState.showPhotoLibrary) {
        PhotoLibraryView(image: $image)
      }
      .loading($uiState.loading, showAlert: $uiState.showAlert)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Text("キャンセル")
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            save()
          } label: {
            Text("保存")
          }
          .disabled(uiState.name.isEmpty || image == nil)
        }
      }
    }
  }
}

private extension CreateDogPage {
  func dog() -> Dog {
    Dog(
      name: uiState.name,
      birthDate: .init(date: uiState.bitrhDate),
      biologicalSex: uiState.biologicalSex
    )
  }

  func save() {
    Task {
      guard let uid = await authenticator.user()?.uid else { return }
      uiState.loading = .loading
      let query: Query.Dog = .all(uid: uid)
      var newDog = dog()
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
