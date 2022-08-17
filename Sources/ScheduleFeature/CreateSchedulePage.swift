import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CreateSchedulePage: View {
  private struct UiState {
    var allDay: Bool = false
    var dogs: [Dog] = []
    var loadingState: Loading = .idle
    var memo: String = ""
    var notificationDate: Set<NotificationDate> = []
    var ownerId: String = ""
    var schedule: Date = .init()
    var selectedDogs: Set<Dog> = []
    var showAlert = false
    var showDogsModal = false
    var showNotificationModal = false
    var title: String = ""
  }
  private let db = Firestore.firestore()
  private let authenticator: Authenticator = .live

  @Environment(\.dismiss) var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  public init() {}

  public var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: Padding.medium) {
          ContentSection(
            title: $uiState.title,
            memo: $uiState.memo,
            focused: _focused
          )

          DogsSection(
            showDogsModal: $uiState.showDogsModal,
            focused: _focused,
            dogs: uiState.selectedDogs
          )

          ScheduleSection(
            allDay: $uiState.allDay,
            schedule: $uiState.schedule,
            focused: _focused
          )

          SettingSection(
            showNotificationModal: $uiState.showNotificationModal,
            focused: _focused
          )

          Spacer()
        }
        .padding(Padding.xSmall)
      }
      .halfModal(isShow: $uiState.showDogsModal) {
        List(uiState.dogs, selection: $uiState.selectedDogs) { dog in
          Text(dog.name).tag(dog)
        }
        .environment(\.editMode, .constant(.active))
      } onEnd: { }
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
      } onEnd: { }
      .loading($uiState.loadingState, showAlert: $uiState.showAlert)
      .background(Color.Background.primary)
      .navigationTitle("新規予定")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Text("キャンセル")
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            Task {
              do {
                for schedule in schedules() {
                  try await db.set(schedule, reference: db.schedules(uid: schedule.ownerId, dogId: schedule.dogId))
                }
                uiState.loadingState = .loaded
                dismiss()
              } catch let loadingError as LoadingError {
                uiState.loadingState = .failed(error: loadingError)
              }
            }
          } label: {
            Text("保存")
          }
          .disabled(uiState.title.isEmpty)
        }
      }
      .task {
        guard let uid = await authenticator.user()?.uid else { return }
        uiState.ownerId = uid
        do {
          if let dogs = try await db.get(db.dogs(uid: uid), type: Dog.self) {
            uiState.dogs = dogs
          }
        } catch {
        }
      }
    }
  }

  private struct ContentSection: View {
    @Binding var title: String
    @Binding var memo: String
    @FocusState var focused: Bool

    var body: some View {
      VStack {
        TextField("タイトル", text: $title)
          .padding(Padding.xSmall)
          .focused($focused)

        Divider()
          .padding(.leading, Padding.xSmall)

        TextEditorWithPlaceholder("メモ", text: $memo)
          .frame(height: 60, alignment: .topLeading)
          .padding(Padding.xSmall)
          .focused($focused)
      }
      .background(Color.Background.secondary)
      .clipShape(
        RoundedRectangle(cornerRadius: 8)
      )
    }
  }

  private struct DogsSection: View {
    @Binding var showDogsModal: Bool
    @FocusState var focused: Bool
    let dogs: Set<Dog>

    var body: some View {
      VStack {
        Button {
          focused = false
          showDogsModal = true
        } label: {
          HStack {
            Image.person
              .frame(width: 16, height: 16)
              .foregroundColor(.white)
              .padding(6)
              .background(.blue)
              .cornerRadius(6)

            if dogs.isEmpty {
              Text("ワンちゃんを選択してください")
            } else {
              ForEach(Array(dogs)) { dog in
                Text(dog.name)
              }
            }

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
    }
  }

  private struct ScheduleSection: View {
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

  private struct SettingSection: View {
    @Binding var showNotificationModal: Bool
    @FocusState var focused: Bool

    var body: some View {
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
      .padding(Padding.small)
      .background(Color.Background.secondary)
      .clipShape(
        RoundedRectangle(cornerRadius: 8)
      )
    }
  }
}

private extension CreateSchedulePage {
  func schedules() -> [Schedule] {
    uiState.selectedDogs.map { dog in
      Schedule(
        date: .init(date: uiState.schedule),
        content: uiState.title,
        complete: false,
        notificationDate: uiState.notificationDate.map { notification in .init(date: notification.date(from: uiState.schedule)) },
        ownerId: uiState.ownerId,
        dogId: dog.id!
      )
    }
  }
}

struct CreateSchedulePage_Previews: PreviewProvider {
  static var previews: some View {
    CreateSchedulePage()
  }
}
