import Styleguide
import SwiftUI

struct NameSection: View {
  @Binding var name: String

  var body: some View {
    VStack(alignment: .leading, spacing: Padding.xSmall) {
      HStack {
        Text("名前")
          .font(.caption)
          .foregroundColor(Color.Label.secondary)

        Spacer()
      }

      TextField("名前", text: $name)
        .padding(Padding.small)
        .background(Color.Background.secondary)
        .clipShape(
          RoundedRectangle(cornerRadius: 8)
        )
    }
  }
}
