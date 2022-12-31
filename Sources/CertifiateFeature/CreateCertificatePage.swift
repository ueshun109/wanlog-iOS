import Core
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
  private struct UiState {
    var date: Date = .now
    var dogs: [Dog] = []
    var images: LimitedArray<UIImage?> = .init(3)
    var loading: Loading = .idle {
      didSet {
        switch loading {
        case .idle, .loading, .loaded:
          break
        case .failed:
          showAlert = true
        }
      }
    }
    var memo: String = ""
    var ownerId: String = ""
    var pick: Pick = .new
    var selectedDog: Dog?
    var selectImageIndex: Int?
    var showAlert = false
    var showCamera = false
    var showConfirmationDialog = false
    var showDogModal = false
    var showPhotoLibrary = false
    var title: String = ""
  }

  @Environment(\.dismiss) private var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()

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
        disabledSave:(
          !validateCertificate(
            title: uiState.title,
            images: uiState.images,
            dog: uiState.selectedDog
          ) || uiState.loading == .loading
        )
      ) {
        dismiss()
      } onSave: {
        uiState.loading = .loading
        Task {
          if await save() {
            dismiss()
          }
        }
      }
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
        CameraView { image in
          uiState.images.append(image)
        }
      case .change(let index):
        CameraView(image: $uiState.images[index])
      }
    }
    .sheet(isPresented: $uiState.showPhotoLibrary) {
      switch uiState.pick {
      case .new:
        PhotoLibraryView { image in
          uiState.images.append(image)
        }
      case .change(let index):
        PhotoLibraryView(image: $uiState.images[index])
      }
    }
    .loading($uiState.loading, showAlert: $uiState.showAlert)
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      uiState.ownerId = uid
      do {
        let query: Query.Dog = .all(uid: uid)
        if let dogs = try await db.get(query: query.collection(), type: Dog.self) {
          uiState.dogs = dogs
        }
      } catch {
      }
    }
  }

  // MARK: - Sections

  private struct ToolBar: ToolbarContent {
    let disabledSave: Bool
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
        .disabled(disabledSave)
      }
    }
  }
}

private extension CreateCertificatePage {
  func certificate() -> Certificate? {
    guard let dogId = uiState.selectedDog?.id else { return nil }
    return Certificate(
      dogId: dogId,
      title: uiState.title,
      description: uiState.memo,
      imageRefs: [],
      date: .init(date: uiState.date),
      ownerId: uiState.ownerId
    )
  }

  func save() async -> Bool {
    guard let dogId = uiState.selectedDog?.id,
          let newCertificate = certificate()
    else { return false }

    let certificateRef: DocumentReference?
    let createdCertificate: Certificate?

    do {
      certificateRef = try await CertifiateFeature.save(
        certificate: newCertificate,
        uid: uiState.ownerId,
        dogId: dogId
      )
      if let certificateRef {
        let db = Firestore.firestore()
        createdCertificate = try await db.get(certificateRef, type: Certificate.self)
      } else {
        createdCertificate = nil
      }
    } catch let loadingError as LoadingError {
      uiState.loading = .failed(error: loadingError)
      return false
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      uiState.loading = .failed(error: loadingError)
      return false
    }

    guard var createdCertificate else { return false }

    do {
      let imagePaths = try await CertifiateFeature.create(
        images: uiState.images.toArray(),
        uid: uiState.ownerId,
        dogId: dogId,
        folderName: createdCertificate.createdAt!.dateValue().ISO8601Format(),
        existedImageCount: 0
      )
      guard let ref = certificateRef else {
        throw LoadingError(errorDescription: "Failed upload data.")
      }
      createdCertificate.imageRefs = imagePaths
      try await db.set(createdCertificate, documentReference: ref)
    } catch let loadingError as LoadingError {
      guard let ref = certificateRef else { return false }
      try? await db.remove(ref)
      uiState.loading = .failed(error: loadingError)
      return false
    } catch {
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      uiState.loading = .failed(error: loadingError)
      return false
    }
    return true
  }
}
