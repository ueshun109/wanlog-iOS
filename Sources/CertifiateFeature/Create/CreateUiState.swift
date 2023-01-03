import Core
import SharedModels
import SwiftUI

extension CreateCertificatePage {
  struct UiState {
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

    func certificate(dogId: String) -> Certificate {
      Certificate(
        dogId: dogId,
        title: title,
        description: memo,
        imageRefs: [],
        date: .init(date: date),
        ownerId: ownerId
      )
    }

    func enableSaveButton() -> Bool {
      let requiredItem = (!title.isEmpty && images.count >= 1 && selectedDog != nil)
      let isNotLoading = loading != .loading
      return requiredItem && isNotLoading
    }
  }
}
