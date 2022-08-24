import SharedModels
import Styleguide
import SwiftUI

struct BiologicalSexSection: View {
  @Binding var biologicalSex: BiologicalSex

  var body: some View {
    VStack(alignment: .leading, spacing: Padding.xSmall) {
      HStack {
        Text("性別")
          .font(.caption)
          .foregroundColor(Color.Label.secondary)

        Spacer()
      }

      Picker("性別", selection: $biologicalSex) {
        Text("オス").tag(BiologicalSex.male)
        Text("メス").tag(BiologicalSex.female)
      }
      .pickerStyle(.segmented)
      .padding(Padding.small)
      .background(Color.Background.secondary)
      .clipShape(
        RoundedRectangle(cornerRadius: 8)
      )
    }
  }
}
