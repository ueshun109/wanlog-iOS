import Core
import DataStore
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CertificateDetailPage: View {
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  private let certificate: Certificate
  private let getDogList = DogUsecase.getDogList
  private let getImageList = CertificateUsecase.getImageList
  private let saveCertificate = CertificateUsecase.saveCertificate

  public init(certificate: Certificate) {
    self.certificate = certificate
  }

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
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("証明書詳細")
    .toolbar {
      ToolBar(enabledSave: uiState.enableSaveButton(certificate: certificate), onSave: onSave)
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
    } onEnd: {
    }
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
        async let a = getDogList()
        async let b = getImageList(references: certificate.imageRefs)
        let (dogs, images) = try await (a, b)
        uiState.set(dogs: dogs, images: images, certificate: certificate)
      } catch {
      }
    }
  }
}

// MARK: - Components

private extension CertificateDetailPage {
  struct ToolBar: ToolbarContent {
    let enabledSave: Bool
    let onSave: () -> Void

    @ViewBuilder
    var body: some ToolbarContent {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: onSave) {
          Text("保存")
        }
        .disabled(!enabledSave)
      }
    }
  }
}

// MARK: - Events

private extension CertificateDetailPage {
  func onSave() {
    uiState.loading = .loading
    Task {
      do {
        let diff = CollectionDifferenceType(before: uiState.initialImages, after: uiState.images)
        var newCertificate = certificate
        newCertificate.title = uiState.title
        newCertificate.description = uiState.memo
        newCertificate.date = .init(date: uiState.date)
        newCertificate.dogId = uiState.selectedDog!.id!
        try await saveCertificate(newCertificate, diff: diff)
        uiState.loading = .loaded
      } catch {
      }
    }
  }
}

struct CertificateDetailPage_Previews: PreviewProvider {
    static var previews: some View {
      CertificateDetailPage(certificate: .fake)
    }
}
