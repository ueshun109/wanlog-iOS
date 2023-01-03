import Core
import DataStore
import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

enum Pick {
  case new
  case change(index: Int)
}

public struct CreateCertificatePage: View {
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let getDogList = DogUsecase.getDogList
  private let createCertificate = CertificateUsecase.createCertificate

  public init() {}

  public var body: some View {
    ScrollView {
      VStack(spacing: Padding.medium) {
        ImagesSection(
          images: $uiState.images,
          pick: $uiState.pick,
          showConfirmationDialog: $uiState.showConfirmationDialog,
          selectImageIndex: $uiState.selectImageIndex
        )

        ContentSection(
          title: $uiState.title,
          memo: $uiState.memo,
          focused: _focused
        )
        .padding(Padding.xSmall)

        DogSection(
          showDogsModal: $uiState.showDogModal,
          focused: _focused,
          dog: uiState.selectedDog
        )
        .padding(Padding.xSmall)

        DateSection(
          date: $uiState.date,
          focused: _focused
        )
        .padding(Padding.xSmall)
      }
    }
    .background(Color.Background.primary)
    .navigationTitle("証明書追加")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolBar(
        enableSave: uiState.enableSaveButton(),
        onCancel: { dismiss() },
        onSave: onSave
      )
    }
    .confirmationDialog(
      "",
      isPresented: $uiState.showConfirmationDialog,
      titleVisibility: .hidden
    ) {
      PhotoConfirmationDialog(
        showCamera: $uiState.showCamera,
        showPhotoLibrary: $uiState.showPhotoLibrary
      )
    }
    .halfModal(isShow: $uiState.showDogModal) {
      // I want to use `init(_:selection:rowContent:)`, but I have implement it myself.
      // Because the behavior is unstable.
      List(uiState.dogs) { dog in
        DogListItem(selection: $uiState.selectedDog, dog: dog)
      }
    } onEnd: { }
    .sheet(isPresented: $uiState.showCamera) {
      switch uiState.pick {
      case .new:
        CameraView { image in uiState.images.append(image) }
      case .change(let index):
        CameraView(image: $uiState.images[index])
      }
    }
    .sheet(isPresented: $uiState.showPhotoLibrary) {
      switch uiState.pick {
      case .new:
        PhotoLibraryView { image in uiState.images.append(image) }
      case .change(let index):
        PhotoLibraryView(image: $uiState.images[index])
      }
    }
    .loading($uiState.loading, showAlert: $uiState.showAlert)
    .task {
      do {
        guard let uid = await authenticator.user()?.uid else { return }
        uiState.ownerId = uid
        uiState.dogs = try await getDogList()
      } catch {
      }
    }
  }
}

// MARK: - Components

private extension CreateCertificatePage {
  struct ToolBar: ToolbarContent {
    let enableSave: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    @ViewBuilder
    var body: some ToolbarContent {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: onCancel) {
          Text("キャンセル")
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: onSave) {
          Text("保存")
        }
        .disabled(!enableSave)
      }
    }
  }
}

// MARK: - Events

private extension CreateCertificatePage {
  func onSave() {
    guard let dogId = uiState.selectedDog?.id else { return }
    uiState.loading = .loading
    Task {
      do {
        let newCertificate = uiState.certificate(dogId: dogId)
        try await createCertificate(certificate: newCertificate, images: uiState.images)
        uiState.loading = .loaded
        dismiss()
      } catch let loadingError as LoadingError {
        uiState.loading = .failed(error: loadingError)
      } catch {
        let loadingError = LoadingError(errorDescription: error.localizedDescription)
        uiState.loading = .failed(error: loadingError)
      }
    }
  }
}
