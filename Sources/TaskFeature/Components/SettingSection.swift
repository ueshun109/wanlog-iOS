import SharedModels
import Styleguide
import SwiftUI

struct SettingSection: View {
  @Binding var priority: Priority
  @FocusState var focused: Bool
  @State private var showPopover = false

  var body: some View {
    Section {
      Menu {
        ForEach(Priority.allCases, id: \.self) { item in
          Button(item.title) {
            priority = item
          }
        }
      } label: {
        HStack {
          Image.exclamationmarkCircleFill
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(.white)
            .padding(6)
            .background(.yellow)
            .cornerRadius(6)

          Text("重要度")

          Spacer()

          Text(priority.title)
        }
      }
      .foregroundColor(Color.Label.primary)
    } header: {
      Button {
        showPopover = true
      } label: {
        HStack {
          Image.infoCircle
          Text("重要度について")
            .fontWithLineHeight(font: .hiraginoSans(.caption1))
        }
        .foregroundColor(Color.Label.secondary)
      }
      .popover(isPresented: $showPopover) {
        Text("重要度が「高」に設定されたタスクは、ホームの上部に表示されるようになります。")
          .padding()
      }
    }
  }
}

struct SettingSection_Previews: PreviewProvider {
  static var previews: some View {
    SettingSection(priority: .constant(.medium))
  }
}
