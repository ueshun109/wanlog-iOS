import Styleguide
import SwiftUI

struct TaskSection: View {
  @Binding var allDay: Bool
  @Binding var expiredDate: Date
  @FocusState var focused: Bool
  @State private var openDatePicker = false

  var body: some View {
    Section {
      datePicker
      toggle
    }
  }

  private var toggle: some View {
    Toggle(isOn: $allDay) {
      HStack {
        Image.clockArrowCirclePath
          .frame(width: 16, height: 16)
          .foregroundColor(.white)
          .padding(6)
          .background(.green)
          .cornerRadius(6)
        Text("終日")
      }
    }
  }

  @ViewBuilder
  private var datePicker: some View {
    Button {
      focused = false
      withAnimation {
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
          Text("期日")
          Text(expiredDate.formatted(date: .complete, time: allDay ? .omitted : .shortened))
        }
        Spacer()
      }
    }
    .foregroundColor(Color.Label.primary)

    if openDatePicker {
      DatePicker(
        selection: $expiredDate,
        displayedComponents: datePickerComponents(allDay: allDay)
      ) {
      }
      .datePickerStyle(.graphical)
    }
  }

  func datePickerComponents(allDay: Bool) -> DatePickerComponents {
    allDay ? [.date] : [.date, .hourAndMinute]
  }
}
