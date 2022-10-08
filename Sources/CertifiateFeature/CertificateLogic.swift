import SharedModels
import SwiftUI

func validateCertificate<Images: Collection>(
  title: String,
  images: Images,
  dog: Dog?
) -> Bool {
  !title.isEmpty && images.count >= 1 && dog != nil
}
