import SwiftUI
import AVFoundation

//public struct CameraView: UIViewRepresentable {
//
//}

//class CameraView: UIView {
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//
//    let session = AVCaptureSession()
//    guard let device: AVCaptureDevice = .default(for: .video) else { return }
//    let input: AVCaptureDeviceInput = try! .init(device: device)
//    let output: AVCapturePhotoOutput = .init()
//
//    session.addInput(input)
//    session.addOutput(output)
//    session.startRunning()
//
//    let videoLayer = AVCaptureVideoPreviewLayer(session: session)
//    layer.addSublayer(videoLayer)
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//}

public struct CameraView: UIViewControllerRepresentable {
  @Binding private var image: UIImage?
  @Environment(\.dismiss) var dismiss

  public init(image: Binding<UIImage?>) {
    self._image = image
  }

  public func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = context.coordinator
    imagePicker.sourceType = .camera
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
      }
      parent.dismiss()
    }
  }
}
