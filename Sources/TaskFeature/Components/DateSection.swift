import SharedModels
import Styleguide
import SwiftUI

struct DateSection: View {
  @Binding var showReminderDate: Bool
  @Binding var showRepeatDate: Bool
  @FocusState var focused: Bool
  let selectedReminderDate: Set<ReminderDate>
  let selectedRepeatDate: RepeatDate?

  var body: some View {
    Section {
      Button {
        focused = false
        showRepeatDate = true
      } label: {
        LabeledContent {
          Text(selectedRepeatDate?.rawValue ?? "指定なし")
            .foregroundColor(Color.Label.secondary)
        } label: {
          HStack {
            Image.repeat
              .resizable()
              .frame(width: 16, height: 16)
              .foregroundColor(.white)
              .padding(6)
              .background(.gray.opacity(0.6))
              .cornerRadius(6)

            Text("繰り返し")

            Spacer()
          }
        }
      }

      Button {
        focused = false
        showReminderDate = true
      } label: {
        LabeledContent {
          Text(summaryReminderDate.isEmpty ? "指定なし" : summaryReminderDate)
            .foregroundColor(Color.Label.secondary)
        } label: {
          HStack {
            Image.bell
              .resizable()
              .frame(width: 16, height: 16)
              .foregroundColor(.white)
              .padding(6)
              .background(.orange)
              .cornerRadius(6)

            Text("通知")

            Spacer()
          }
        }
      }
    }
    .foregroundColor(Color.Label.primary)
  }

  private var summaryReminderDate: String {
    var sorted = selectedReminderDate.sorted(by: { $0.id < $1.id })
    if sorted.last == .atStart {
      sorted.move(fromOffsets: IndexSet([sorted.count - 1]), toOffset: 0)
    }
    return sorted.map { $0.id }.joined(separator: ",")
  }
}
