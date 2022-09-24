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
                  let query: Query.Schedule = .perDog(uid: schedule.ownerId, dogId: schedule.dogId)
                  try await db.set(schedule, collectionReference: query.collection())
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
          let query: Query.Dog = .all(uid: uid)
          if let dogs = try await db.get(query: query.collection(), type: Dog.self) {
            uiState.dogs = dogs
          }
        } catch {
        }
      }
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
        memo: uiState.memo,
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
