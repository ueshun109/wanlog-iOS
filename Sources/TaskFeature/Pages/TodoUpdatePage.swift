import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct TodoUpdatePage: View {
  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()
  private let todo: Todo

  @Environment(\.dismiss) var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  public init(todo: Todo) {
    self.todo = todo
  }

  public var body: some View {
    NavigationView {
      List {
        ContentSection(
          title: $uiState.title,
          memo: $uiState.memo,
          focused: _focused
        )

        dogSection(name: uiState.dog?.name ?? "")

        TaskSection(
          allDay: $uiState.allDay,
          expiredDate: $uiState.expiredDate,
          focused: _focused
        )

        DateSection(
          showReminderDate: $uiState.showReminderDateModal,
          showRepeatDate: $uiState.showRpeatDate,
          focused: _focused,
          selectedReminderDate: uiState.reminderDates,
          selectedRepeatDate: uiState.repeatDate
        )

        SettingSection(
          priority: $uiState.priority,
          focused: _focused
        )
      }
      .listStyle(.insetGrouped)
      .halfModal(isShow: $uiState.showRpeatDate) {
        SingleSelectionList(selection: $uiState.repeatDate, headerTitle: "繰り返し")
      }
      .halfModal(isShow: $uiState.showReminderDateModal) {
        MultiSelectionList(selections: $uiState.reminderDates, headerTitle: "リマインド通知")
      }
      .loading($uiState.loadingState, showAlert: $uiState.showAlert)
      .background(Color.Background.primary)
      .navigationTitle("詳細")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        cancelButton
        saveButton
      }
    }
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      let repeatDateSeconds = todo.repeatDate?.seconds ?? 0
      let diff = TimeInterval(repeatDateSeconds - todo.expiredDate.seconds)
      let reminderDates = todo.reminderDates?.compactMap {
        Todo.ReminderDate(lhs: todo.expiredDate.dateValue(), rhs: $0.dateValue())
      } ?? []

      uiState.expiredDate = todo.expiredDate.dateValue()
      uiState.memo = todo.memo ?? ""
      uiState.ownerId = uid
      uiState.priority = todo.priority
      uiState.repeatDate = .init(timeInterval: diff)
      uiState.reminderDates = Set(reminderDates)
      uiState.title = todo.content

      do {
        let query: Query.Dog = .one(uid: uid, dogId: todo.dogId)
        if let dog = try await db.get(query.document(), type: Dog.self) {
          uiState.dog = dog
        }
      } catch {
      }
    }
  }

  /// 🐶 Dog section.
  func dogSection(name: String) -> some View {
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
  }

  /// ❎ Canel button.
  private var cancelButton: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button {
        dismiss()
      } label: {
        Text("キャンセル")
      }
    }
  }

  /// ✅ Save button.
  private var saveButton: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        Task {
          do {
            guard let id = todo.id else { return }
            let new = uiState.todo(id: id, complete: todo.complete)
            let query: Query.Todo = .one(uid: todo.ownerId, dogId: todo.dogId, taskId: id)
            try await db.set(new, documentReference: query.document())
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

// MARK: - UiState

private extension TodoUpdatePage {
  struct UiState {
    var allDay: Bool = false
    var dog: Dog?
    var expiredDate: Date = .init()
    var loadingState: Loading = .idle
    var memo: String = ""
    var ownerId: String = ""
    var priority: Todo.Priority = .medium
    var repeatDate: Todo.Interval?
    var reminderDates: Set<Todo.ReminderDate> = []
    var showAlert = false
    var showReminderDateModal = false
    var showRpeatDate = false
    var title: String = ""
  }
}

private extension TodoUpdatePage.UiState {
  func todo(id: String?, complete: Bool) -> Todo {
    let repeatDate: Timestamp?
    if let date = self.repeatDate?.date(expiredDate) {
      repeatDate = .init(date: date)
    } else {
      repeatDate = nil
    }
    return .init(
      id: id,
      content: title,
      complete: complete,
      dogId: dog!.id!,
      expiredDate: .init(date: expiredDate),
      memo: memo,
      ownerId: ownerId,
      priority: priority,
      reminderDates: reminderDates.map { .init(date: $0.date(expiredDate)) },
      repeatDate: repeatDate
    )
  }
}
