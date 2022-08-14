import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CreateSchedulePage: View {
  private struct UiState {
    var title: String = ""
    var memo: String = ""
    var allDay: Bool = false
    var schedule: Date = .init()
    var showNotificationModal = false
    var openSchedule: Bool = false
    var notificationDate: Set<NotificationDate> = []
  }

  private func datePickerComponents(allDay: Bool) -> DatePickerComponents {
    allDay ? [.date] : [.date, .hourAndMinute]
  }

  @State private var uiState = UiState()
  @FocusState private var focused: Bool

  public init() {}

  public var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: Padding.medium) {
          VStack {
            TextField("タイトル", text: $uiState.title)
              .padding(Padding.xSmall)
              .focused($focused)

            Divider()
              .padding(.leading, Padding.xSmall)

            TextEditorWithPlaceholder("メモ", text: $uiState.memo)
              .frame(height: 60, alignment: .topLeading)
              .padding(Padding.xSmall)
              .focused($focused)
          }
          .background(Color.Background.secondary)
          .clipShape(
            RoundedRectangle(cornerRadius: 8)
          )

          VStack {
            Toggle(isOn: $uiState.allDay) {
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
                  uiState.openSchedule.toggle()
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
                    Text(uiState.schedule.formatted(date: .complete, time: uiState.allDay ? .omitted : .shortened))
                  }
                  Spacer()
                }
              }
              .foregroundColor(Color.Label.primary)

              if uiState.openSchedule {
                DatePicker(
                  selection: $uiState.schedule,
                  displayedComponents: datePickerComponents(allDay: uiState.allDay)
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

          VStack {
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

            Divider()
              .padding(.trailing, -Padding.xSmall)

            Button {
              focused = false
              uiState.showNotificationModal = true
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
          .padding(Padding.small)
          .background(Color.Background.secondary)
          .clipShape(
            RoundedRectangle(cornerRadius: 8)
          )

          Spacer()
        }
        .padding(Padding.xSmall)
      }
      .halfModal(isShow: $uiState.showNotificationModal) {
        VStack(alignment: .leading, spacing: 0) {
          Text("予定のリマインド通知")
            .padding(.top, Padding.large)
            .padding(.leading, Padding.small)

          List(selection: $uiState.notificationDate) {
            Text(NotificationDate.atStart.title).tag(NotificationDate.atStart)
            Text(NotificationDate.tenMinutesAgo.title).tag(NotificationDate.tenMinutesAgo)
            Text(NotificationDate.oneHourAgo.title).tag(NotificationDate.oneHourAgo)
          }
          .environment(\.editMode, .constant(.active))

          Spacer()
        }
      } onEnd: {
        uiState.showNotificationModal = false
      }
      .background(Color.Background.primary)
      .navigationTitle("新規予定")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {

          } label: {
            Text("キャンセル")
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button {

          } label: {
            Text("保存")
          }
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
