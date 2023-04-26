import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct UpdateTaskPage: View {
  private struct UiState {
    var allDay: Bool = false
    var dog: Dog?
    var expiredDate: Date = .init()
    var loadingState: Loading = .idle
    var memo: String = ""
    var ownerId: String = ""
    var priority: Priority = .medium
    var reminderDate: Set<ReminderDate> = []
    var showAlert = false
    var showReminderDateModal = false
    var title: String = ""
  }

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

        DogSection(name: uiState.dog?.name ?? "")

        TaskSection(
          allDay: $uiState.allDay,
          expiredDate: $uiState.expiredDate,
          focused: _focused
        )

        DateSection(
          showReminderDate: $uiState.showReminderDateModal,
          showRepeatDate: .constant(false),
          focused: _focused,
          selectedReminderDate: [],
          selectedRepeatDate: nil
        )

        SettingSection(
          priority: $uiState.priority,
          focused: _focused
        )
      }
      .listStyle(.insetGrouped)
      .halfModal(isShow: $uiState.showReminderDateModal) {
        MultiSelectionList(selections: $uiState.reminderDate, headerTitle: "リマインド通知")
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
      uiState.ownerId = uid
      uiState.title = todo.content
      uiState.memo = todo.memo ?? ""
      uiState.expiredDate = todo.expiredDate.dateValue()
      let reminderDate = todo.reminderDate?.compactMap {
        ReminderDate(lhs: todo.expiredDate.dateValue(), rhs: $0.dateValue())
      }
      if let reminderDate { uiState.reminderDate = Set(reminderDate) }
      do {
        let query: Query.Dog = .one(uid: uid, dogId: todo.dogId)
        if let dog = try await db.get(query.document(), type: Dog.self) {
          uiState.dog = dog
        }
      } catch {
      }
    }
  }

  private var cancelButton: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button {
        dismiss()
      } label: {
        Text("キャンセル")
      }
    }
  }

  private var saveButton: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        Task {
          do {
            guard let id = todo.id else { return }
            let task = createTodo()
            let query: Query.Todo = .one(uid: todo.ownerId, dogId: todo.dogId, taskId: id)
            try await db.set(todo, documentReference: query.document())
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
    }
  }
}

private extension UpdateTaskPage {
  func createTodo() -> Todo {
    .init(
      id: todo.id,
      content: uiState.title,
      complete: todo.complete,
      dogId: uiState.dog!.id!,
      expiredDate: .init(date: uiState.expiredDate),
      memo: uiState.memo,
      ownerId: uiState.ownerId,
      priority: uiState.priority,
      reminderDate:  uiState.reminderDate.map { .init(date: $0.date(uiState.expiredDate)) }
    )
  }
}
