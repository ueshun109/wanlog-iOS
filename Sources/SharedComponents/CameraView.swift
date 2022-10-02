import AVFoundation
import SwiftUI

public struct CameraView: UIViewControllerRepresentable {
  @Binding private var image: UIImage?
  @Environment(\.dismiss) var dismiss
  private let onSelect: ((UIImage) -> Void)?

  public init(
    image: Binding<UIImage?>,
    onSelect: ((UIImage) -> Void)?
  ) {
    self._image = image
    self.onSelect = onSelect
  }

  public func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = context.coordinator
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = true
    return imagePicker
  }

  public func updateUIViewController(
    _ uiViewController: UIImagePickerController,
    context: Context
  ) {
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: CameraView

    public init(_ parent: CameraView) {
      self.parent = parent
    }

    public func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        parent.image = image
        parent.onSelect?(image)
      }
      parent.dismiss()
    }
  }
}

public extension CameraView {
  init(image: Binding<UIImage?>) {
    self.init(image: image, onSelect: nil)
  }

  init(onSelect: ((UIImage) -> Void)?) {
    self.init(image: .constant(nil), onSelect: onSelect)
  }
}
