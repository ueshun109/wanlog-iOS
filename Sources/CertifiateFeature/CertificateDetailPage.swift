import Core
import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CertificateDetailPage: View {
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
    var initialImages: LimitedArray<UIImage?> = .init(3)
    var memo = ""
    var ownerId = ""
    var pick: Pick = .new
    var selectedDog: Dog?
    var selectImageIndex: Int?
    var showAlert = false
    var showCamera = false
    var showConfirmationDialog = false
    var showDogModal = false
    var showPhotoLibrary = false
    var title = ""

    var dic: LimitedDictionary<String, UIImage?> = .init(3)

    func isUpdate(certificate: Certificate) -> Bool {
      !(
        certificate.title == title &&
        certificate.description == memo &&
        certificate.date.dateValue() == date &&
        certificate.dogId == selectedDog?.id &&
        initialImages == images
      )
    }
  }
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let certificate: Certificate
  private let db = Firestore.firestore()
  private let storage: Storage = .storage()

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
      ToolBar(
        disabledSave:(
          !validateCertificate(
            title: uiState.title,
            images: uiState.images,
            dog: uiState.selectedDog
          ) ||
          !uiState.isUpdate(certificate: certificate) ||
          uiState.loading == .loading
        )
      ) {
        uiState.loading = .loading
        Task {
          await save()
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
    } onEnd: {
    }
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
    .onAppear {
      uiState.title = certificate.title
      uiState.date = certificate.date.dateValue()
      if let memo = certificate.description {
        uiState.memo = memo
      }
    }
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      uiState.ownerId = uid
      async let dogs = dogs()
      async let images = images()
      let pair = await (dogs, images)
      uiState.dogs = pair.0
      uiState.images = .init(3, elements: pair.1)
      uiState.initialImages = uiState.images

      for i in certificate.imageRefs.indices {
        let key = certificate.imageRefs[i]
        uiState.dic[key] = uiState.images[i]
      }

      uiState.selectedDog = pair.0.first(where: { certificate.dogId == $0.id })
      if !pair.1.isEmpty { uiState.selectImageIndex = 0 }
    }
  }

  private struct ToolBar: ToolbarContent {
    let disabledSave: Bool
    let onSave: () -> Void

    @ViewBuilder
    var body: some ToolbarContent {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: onSave) {
          Text("保存")
        }
        .disabled(disabledSave)
      }
    }
  }
}

private extension CertificateDetailPage {
  func dogs() async -> [Dog] {
    guard let uid = await authenticator.user()?.uid else { return [] }
    uiState.ownerId = uid
    do {
      let query: Query.Dog = .all(uid: uid)
      if let dogs = try await db.get(query: query.collection(), type: Dog.self) {
        return dogs
      } else {
        return []
      }
    } catch {
      return []
    }
  }

  func images() async -> [UIImage] {
    var images: [UIImage] = []
    for ref in certificate.imageRefs {
      guard let data = try? await storage.reference(withPath: ref).get(),
            let image = UIImage(data: data)
      else { continue }
      images.append(image)
    }
    return images
  }

  func save() async {
    let diff = CollectionDifferenceType(before: uiState.initialImages, after: uiState.images)
    switch diff {
    case .onlyUpdated(let updated):
      let pathsAndImages = Dictionary(uniqueKeysWithValues: zip(certificate.imageRefs, updated))
      do {
        try await update(items: pathsAndImages)
      } catch {
        // TODO: 更新に失敗した場合のエラーハンドリング
      }
    case .increased(let updated, let inserted):
      let updatedPathsAndImages = Dictionary(uniqueKeysWithValues: zip(certificate.imageRefs, updated))
      do {
        try await update(items: updatedPathsAndImages)
        let imagePaths = try await create(
          images: inserted,
          uid: certificate.ownerId,
          dogId: certificate.dogId,
          folderName: certificate.createdAt!.dateValue().ISO8601Format(),
          existedImageCount: certificate.imageRefs.count
        )
        let newImageRefs = certificate.imageRefs + imagePaths
        var newCertificate = certificate
        newCertificate.imageRefs = newImageRefs
        try await update(certificate: newCertificate, uid: certificate.ownerId, dogId: certificate.dogId, certificateId: certificate.id!)
      } catch {
        // TODO: エラーハンドリング
      }
    case .decreased(let updated, _):
      let updatedPathsAndImages = Dictionary(uniqueKeysWithValues: zip(certificate.imageRefs, updated))
      do {
        try await remove(paths: certificate.imageRefs)
        try await update(items: updatedPathsAndImages)
        let newImageRefs: [String] = Array(updatedPathsAndImages.keys)
        var newCertificate = certificate
        newCertificate.imageRefs = newImageRefs
        try await update(certificate: newCertificate, uid: certificate.ownerId, dogId: certificate.dogId, certificateId: certificate.id!)
      } catch {
        // TODO: エラーハンドリング
      }
    case .noChange:
      break
    }
  }
}

struct CertificateDetailPage_Previews: PreviewProvider {
    static var previews: some View {
      CertificateDetailPage(certificate: .fake)
    }
}

extension Array {
  func toDictionary<Key: Hashable>(with keys: [Key]) -> [Key: Element] {
    var index = 0
    let dictionary = self.reduce([Key: Element]()) { result, element -> [Key: Element] in
      var result = result
      let key = keys[index]
      result[key] = element
      index += 1
      return result
    }
    return dictionary
  }
}

extension Zip2Sequence {
  func toDictionary() -> [Sequence1.Element: Sequence2.Element] where Sequence1.Element: Hashable {
    self.reduce([Sequence1.Element: Sequence2.Element]()) { result, element -> [Sequence1.Element: Sequence2.Element] in
      var result = result
      result[element.0] = element.1
      return result
    }
  }
}
