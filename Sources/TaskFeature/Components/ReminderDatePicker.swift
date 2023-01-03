import SharedModels
import Styleguide
import SwiftUI

struct ReminderDatePicker: View {
  @Binding var reminderDate: Set<ReminderDate>

  var body: some View {
    List(selection: $reminderDate) {
      Section {
        ForEach(ReminderDate.all) { reminder in
          Text(reminder.title).tag(reminder)
        }
      } header: {
        Text("予定のリマインド通知")
          .padding(.vertical, Padding.xSmall)
      }
    }
    .environment(\.editMode, .constant(.active))
  }
}

struct ReminderDatePicker_Previews: PreviewProvider {
  @State private static var selection: Set<ReminderDate> = []
  static var previews: some View {
    ReminderDatePicker(reminderDate: $selection)
  }
}
