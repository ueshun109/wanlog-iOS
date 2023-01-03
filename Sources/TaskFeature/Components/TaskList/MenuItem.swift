import Styleguide
import SwiftUI

/// Menu item displayed on the toolbar.
struct MenuItem: View {
  @Binding var showOnlyIncompleted: Bool

  var body: some View {
    Menu {
      Button {
        showOnlyIncompleted.toggle()
      } label: {
        if showOnlyIncompleted {
          HStack {
            Text("完了済みを表示")
            Spacer()
            Image.eye
          }
        } else {
          HStack {
            Text("完了済みを非表示")
            Spacer()
            Image.eyeSlash
          }
        }
      }
    } label: {
      Image.ellipsisCircle
    }
  }
}

struct MenuItem_Previews: PreviewProvider {
  @State static var toggle = false

  static var previews: some View {
    MenuItem(showOnlyIncompleted: $toggle)
  }
}
