import Styleguide
import SwiftUI

struct DateSection: View {
  @Binding var date: Date
  @FocusState var focused: Bool
  @State var openDatePicker: Bool = false

  var body: some View {
    VStack {
      Button {
        withAnimation {
          focused = false
          openDatePicker.toggle()
        }
      } label: {
        HStack {
          Image.calendar
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(.white)
            .padding(6)
            .background(.red)
            .cornerRadius(6)

          VStack(alignment: .leading) {
            Text("日付")
            Text(date.formatted(date: .complete, time: .omitted))
          }
          Spacer()
        }
      }
      .foregroundColor(Color.Label.primary)

      if openDatePicker {
        DatePicker(
          selection: $date,
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
