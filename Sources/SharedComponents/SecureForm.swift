import Styleguide
import SwiftUI

public struct SecureForm: View {
  @Binding private var text: String
  private let placeholder: String

  public init(
    text: Binding<String>,
    placeholder: String
  ) {
    self._text = text
    self.placeholder = placeholder
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: Padding.xSmall) {
      Text(placeholder)
        .padding(.horizontal, Padding.xSmall)
        .foregroundColor(Color.Label.secondary)
        .fontWithLineHeight(font: .hiraginoSans(.caption1))

      SecureField(placeholder, text: $text)
        .foregroundColor(Color.Label.primary)
        .fontWithLineHeight(font: .hiraginoSans(.callout))
        .padding(Padding.xSmall)
        .background(Color.Fill.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}
