import Styleguide
import SwiftUI

struct ScheduleSection: View {
  @Binding var allDay: Bool
  @Binding var schedule: Date
  @FocusState var focused: Bool
  @State var openSchedule: Bool = false

  var body: some View {
    VStack {
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

      Divider()
        .padding(.trailing, -Padding.xSmall)

      VStack {
        Button {
          focused = false
          withAnimation {
            openSchedule.toggle()
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
              Text(schedule.formatted(date: .complete, time: allDay ? .omitted : .shortened))
            }
            Spacer()
          }
        }
        .foregroundColor(Color.Label.primary)

        if openSchedule {
          DatePicker(
            selection: $schedule,
            displayedComponents: datePickerComponents(allDay: allDay)
          ) {
          }
          .datePickerStyle(.graphical)
        }
      }
    }
    .padding(Padding.small)
    .background(Color.Background.secondary)
    .clipShape(
      RoundedRectangle(cornerRadius: 8)
    )
  }

  func datePickerComponents(allDay: Bool) -> DatePickerComponents {
    allDay ? [.date] : [.date, .hourAndMinute]
  }
}
