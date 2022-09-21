import PhotosUI
import SwiftUI

public struct PhotoLibraryView: UIViewControllerRepresentable {
  @Binding private var image: UIImage?
  @Environment(\.dismiss) var dismiss

  public init(image: Binding<UIImage?>) {
    self._image = image
  }

  public func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.preferredAssetRepresentationMode = .current
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }

  public func updateUIViewController(
    _ uiViewController: PHPickerViewController,
    context: Context
  ) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public class Coordinator: NSObject, PHPickerViewControllerDelegate {
    private let parent: PhotoLibraryView

    public init(_ parent: PhotoLibraryView) {
      self.parent = parent
    }

    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
        parent.dismiss(); return
      }
      provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
        guard let self = self else { return }
        guard error == nil else { self.parent.dismiss(); return }
        self.parent.image = image as? UIImage
        self.parent.dismiss()
      }
    }
  }
}
