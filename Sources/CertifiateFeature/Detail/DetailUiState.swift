import Core
import SharedModels
import SwiftUI

extension CertificateDetailPage {
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
    var initialImages: LimitedArray<UIImage?> = .init(3)
    var memo = ""
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

    func hasChanged(certificate: Certificate) -> Bool {
      !(
        certificate.title == title &&
        certificate.description == memo &&
        certificate.date.dateValue() == date &&
        certificate.dogId == selectedDog?.id &&
        initialImages == images
      )
    }

    func enableSaveButton(certificate: Certificate) -> Bool {
      let requiredItem = (!title.isEmpty && images.count >= 1 && selectedDog != nil)
      let hasChanged = hasChanged(certificate: certificate)
      let isNotLoading = loading != .loading
      return requiredItem && hasChanged && isNotLoading
    }

    mutating func set(dogs: [Dog], images: [UIImage], certificate: Certificate) {
      self.title = certificate.title
      self.date = certificate.date.dateValue()
      self.dogs = dogs
      self.images = .init(3, elements: images)
      self.initialImages = self.images
      self.selectedDog = dogs.first(where: { certificate.dogId == $0.id })
      for i in certificate.imageRefs.indices {
        let key = certificate.imageRefs[i]
        dic[key] = self.images[i]
      }
      if let memo = certificate.description { self.memo = memo }
      if !images.isEmpty { self.selectImageIndex = 0 }
    }
  }
}
