import SwiftUI

public struct CreateSchedulePage: View {
  private struct UiState {
    var title: String = ""
    var memo: String = ""
    var allDay: Bool = false
    var schedule: Date = .init()
    var openSchedule: Bool = false
  }

  private func datePickerComponents(allDay: Bool) -> DatePickerComponents {
    allDay ? [.date] : [.date, .hourAndMinute]
  }

  @State private var uiState = UiState()

  public var body: some View {
    List {
      Section {
        TextField("タイトル", text: $uiState.title)

        TextEditor(text: $uiState.memo)
          .frame(height: 60, alignment: .topLeading)
      }

      Section {
        Toggle(isOn: $uiState.allDay) {
          HStack {
            Image(systemName: "clock.arrow.2.circlepath")
              .frame(width: 16, height: 16)
              .foregroundColor(.white)
              .padding(6)
              .background(.green)
              .cornerRadius(6)
            Text("終日")
          }
        }

        VStack(alignment: .leading) {
          HStack {
            Image(systemName: "calendar")
              .resizable()
              .frame(width: 16, height: 16)
              .foregroundColor(.white)
              .padding(6)
              .background(.red)
              .cornerRadius(6)

            VStack(alignment: .leading) {
              Text("日付")
              Text(uiState.schedule.formatted(date: .complete, time: .shortened))
            }
          }
          .onTapGesture {
            withAnimation {
              uiState.openSchedule.toggle()
            }
          }

          VStack {
            if uiState.openSchedule {
              DatePicker(
                selection: $uiState.schedule,
                displayedComponents: datePickerComponents(allDay: uiState.allDay)
              ) {
              }
              .datePickerStyle(.graphical)
              .animation(.default, value: uiState.allDay)
            }
          }
//          .animation(.default, value: uiState.openSchedule)
        }
      }
    }
  }
}

struct CreateSchedulePage_Previews: PreviewProvider {
  static var previews: some View {
    CreateSchedulePage()
  }
}
