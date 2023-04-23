import Styleguide
import SwiftUI

struct ReminderDateSection: View {
  @Binding var showNotificationModal: Bool
  @FocusState var focused: Bool

  var body: some View {
    Section {
      Button {
        focused = false
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

      Button {
        focused = false
        showNotificationModal = true
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
    .foregroundColor(Color.Label.primary)
  }
}
