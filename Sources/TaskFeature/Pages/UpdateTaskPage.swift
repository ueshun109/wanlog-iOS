import FirebaseClient
import SharedModels
import Styleguide
import SwiftUI

public struct UpdateTaskPage: View {
  private struct UiState {
    var allDay: Bool = false
    var dog: Dog?
    var loadingState: Loading = .idle
    var memo: String = ""
    var notificationDate: Set<NotificationDate> = []
    var ownerId: String = ""
    var expiredDate: Date = .init()
    var showAlert = false
    var showNotificationModal = false
    var title: String = ""
  }

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()
  private let task: NormalTask

  @Environment(\.dismiss) var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  public init(task: NormalTask) {
    self.task = task
  }

  public var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: Padding.medium) {
          ContentSection(
            title: $uiState.title,
            memo: $uiState.memo,
            focused: _focused
          )

          DogSection(name: uiState.dog?.name ?? "")

          TaskSection(
            allDay: $uiState.allDay,
            expiredDate: $uiState.expiredDate,
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
      .navigationTitle("詳細")
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
                guard let id = task.id else { return }
                let task = createTask()
                let query: Query.NormalTask = .one(uid: task.ownerId, dogId: task.dogId, taskId: id)
                try await db.set(task, documentReference: query.document())
                uiState.loadingState = .loaded
                dismiss()
              } catch let loadingError as LoadingError {
                uiState.loadingState = .failed(error: loadingError)
              } catch {
                print(error)
              }
            }
          } label: {
            Text("完了")
          }
          .disabled(uiState.title.isEmpty)
        }
      }
    }
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      uiState.ownerId = uid
      uiState.title = task.content
      uiState.memo = task.memo ?? ""
      uiState.expiredDate = task.expiredDate.dateValue()
      let notificationDates = task.reminderDate?.compactMap {
        NotificationDate(lhs: task.expiredDate.dateValue(), rhs: $0.dateValue())
      }
      if let notificationDates {
        uiState.notificationDate = Set(notificationDates)
      }
      do {
        let query: Query.Dog = .one(uid: uid, dogId: task.dogId)
        if let dog = try await db.get(query.document(), type: Dog.self) {
          uiState.dog = dog
        }
      } catch {
      }
    }
  }

  private struct DogSection: View {
    let name: String

    var body: some View {
      HStack {
        Image.person
          .frame(width: 16, height: 16)
          .foregroundColor(.white)
          .padding(6)
          .background(.blue)
          .cornerRadius(6)

        Text(name)

        Spacer()
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

private extension UpdateTaskPage {
  func createTask() -> NormalTask {
    .init(
      id: task.id!,
      content: uiState.title,
      complete: false,
      dogId: uiState.dog!.id!,
      expiredDate: .init(date: uiState.expiredDate),
      memo: uiState.memo,
      ownerId: uiState.ownerId,
      priority: .medium, // TODO: UIで選択できるようにする,
      reminderDate:  uiState.notificationDate.map { notification in
        .init(date: notification.date(from: uiState.expiredDate))
      }
    )
  }
}
