import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct TodoCreatePage: View {
  private struct UiState {
    var allDay: Bool = false
    var dogs: [Dog] = []
    var expiredDate: Date = .init()
    var loadingState: Loading = .idle
    var memo: String = ""
    var ownerId: String = ""
    var priority: Priority = .medium
    var repeatDate: RepeatDate?
    var reminderDate: Set<ReminderDate> = []
    var selectedDogs: Set<Dog> = []
    var showAlert = false
    var showDogsModal = false
    var showReminderDateModal = false
    var showRpeatDate = false
    var title: String = ""
  }

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()

  @Environment(\.dismiss) var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  public init() {}

  public var body: some View {
    NavigationView {
      List {
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

        TaskSection(
          allDay: $uiState.allDay,
          expiredDate: $uiState.expiredDate,
          focused: _focused
        )

        DateSection(
          showReminderDate: $uiState.showReminderDateModal,
          showRepeatDate: $uiState.showRpeatDate,
          focused: _focused,
          selectedReminderDate: uiState.reminderDate,
          selectedRepeatDate: uiState.repeatDate
        )

        SettingSection(
          priority: $uiState.priority,
          focused: _focused
        )
      }
      .listStyle(.insetGrouped)
      .halfModal(isShow: $uiState.showDogsModal) {
        List(uiState.dogs, selection: $uiState.selectedDogs) { dog in
          Text(dog.name).tag(dog)
        }
        .environment(\.editMode, .constant(.active))
      }
      .halfModal(isShow: $uiState.showRpeatDate) {
        SingleSelectionList(selection: $uiState.repeatDate, headerTitle: "繰り返し")
      }
      .halfModal(isShow: $uiState.showReminderDateModal) {
        MultiSelectionList(selections: $uiState.reminderDate, headerTitle: "リマインド通知")
      }
      .loading($uiState.loadingState, showAlert: $uiState.showAlert)
      .navigationTitle("新規作成")
      .navigationBarTitleDisplayMode(.inline)
      .background(Color.Background.primary)
      .toolbar {
        cancelButton
        saveButton
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
            for todo in todos() {
              let query: Query.Todo = .perDog(uid: todo.ownerId, dogId: todo.dogId)
              try await db.set(todo, collectionReference: query.collection())
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
      .disabled(uiState.title.isEmpty || uiState.selectedDogs.isEmpty)
    }
  }
}

private extension TodoCreatePage {
  func todos() -> [Todo] {
    uiState.selectedDogs.map { dog in
      let repeatDate: Timestamp?
      if let date = uiState.repeatDate?.date(uiState.expiredDate) {
        repeatDate = .init(date: date)
      } else {
        repeatDate = nil
      }
      return Todo(
        content: uiState.title,
        complete: false,
        dogId: dog.id!,
        expiredDate: .init(date: uiState.expiredDate),
        memo: uiState.memo,
        ownerId: uiState.ownerId,
        priority: uiState.priority,
        reminderDate: uiState.reminderDate.map { .init(date: $0.date(uiState.expiredDate)) },
        repeatDate: repeatDate
      )
    }
  }
}

struct CreateTaskPage_Previews: PreviewProvider {
  static var previews: some View {
    TodoCreatePage()
  }
}
