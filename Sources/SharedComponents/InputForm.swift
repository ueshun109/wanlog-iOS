import Styleguide
import SwiftUI

public struct InputForm: View {
  @Binding private var text: String
  private let placeholder: String
  private let keyboardType: UIKeyboardType

  public init(
    text: Binding<String>,
    placeholder: String,
    keyboardType: UIKeyboardType = .default
  ) {
    self._text = text
    self.placeholder = placeholder
    self.keyboardType = keyboardType
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: Padding.xSmall) {
      Text(placeholder)
        .padding(.horizontal, Padding.xSmall)
        .foregroundColor(Color.Label.secondary)
        .fontWithLineHeight(font: .hiraginoSans(.caption1))

      TextField(placeholder, text: $text)
        .foregroundColor(Color.Label.primary)
        .fontWithLineHeight(font: .sfPro(.headline))
        .padding(Padding.xSmall)
        .background(Color.Fill.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .keyboardType(keyboardType)
    }
  }
}

struct InputForm_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      InputForm(text: .constant(""), placeholder: "mail address")
    }
  }
}
