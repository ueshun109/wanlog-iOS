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
  }

  @Environment(\.dismiss) var dismiss
  @State private var image: UIImage?
  @State private var showCamera: Bool = false
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
              showCamera.toggle()
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
      .sheet(isPresented: $showCamera) {
        CameraView(image: $image)
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
          .disabled(uiState.name.isEmpty)
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
      let ref = db.dogs(uid: uid)
      var newDog = dog()
      do {
        let docRef = try await db.set(newDog, reference: ref)
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
        try await db.set(data: newDog, reference: docRef)
        uiState.loading = .loaded
        dismiss()
      } catch let loadingError as LoadingError {
        uiState.loading = .failed(error: loadingError)
      }
    }
  }
}
