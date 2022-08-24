import Styleguide
import SwiftUI

struct BirthDateSection: View {
  @Binding var birthDate: Date
  @State var openDatePicker: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: Padding.xSmall) {
      HStack(spacing: Padding.xxSmall) {
        Text("誕生日")
          .font(.caption)
          .foregroundColor(Color.Label.secondary)

        Spacer()
      }

      VStack {
        Button {
          withAnimation {
            openDatePicker.toggle()
          }
        } label: {
          HStack {
            Text(birthDate.formatted(date: .complete, time: .omitted))
            Spacer()
          }
        }
        .foregroundColor(Color.Label.primary)

        if openDatePicker {
          DatePicker(
            selection: $birthDate,
            displayedComponents: [.date]
          ) {
          }
          .datePickerStyle(.graphical)
        }
      }
      .padding(Padding.small)
      .background(Color.Background.secondary)
      .clipShape(
        RoundedRectangle(cornerRadius: 8)
      )
    }
  }
}
