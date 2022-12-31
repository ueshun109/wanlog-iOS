import SwiftUI

struct PhotoConfirmationDialog: View {
  @Binding var showCamera: Bool
  @Binding var showPhotoLibrary: Bool

  var body: some View {
    Button {
      showCamera = true
    } label: {
      Text("写真を撮る")
    }

    Button {
      showPhotoLibrary = true
    } label: {
      Text("写真を選択")
    }
  }
}
