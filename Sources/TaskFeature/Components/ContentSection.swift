import SharedComponents
import Styleguide
import SwiftUI

struct ContentSection: View {
  @Binding var title: String
  @Binding var memo: String
  @FocusState var focused: Bool

  var body: some View {
    Section {
      TextField("タイトル", text: $title)
        .padding(Padding.xSmall)
        .focused($focused)

      TextField("メモ", text: $memo, axis: .vertical)
        .frame(height: 60, alignment: .topLeading)
        .padding(Padding.xSmall)
        .focused($focused)
    }
  }
}
