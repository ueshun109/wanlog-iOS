import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CreateTaskPage: View {
  private struct UiState {
    var allDay: Bool = false
    var dogs: [Dog] = []
    var loadingState: Loading = .idle
    var memo: String = ""
    var ownerId: String = ""
    var expiredDate: Date = .init()
    var reminderDate: Set<ReminderDate> = []
    var selectedDogs: Set<Dog> = []
    var showAlert = false
    var showDogsModal = false
    var showReminderDateModal = false
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

          TaskSection(
            allDay: $uiState.allDay,
            expiredDate: $uiState.expiredDate,
            focused: _focused
          )

          RemindDateSection(
            showNotificationModal: $uiState.showReminderDateModal,
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
      }
      .halfModal(isShow: $uiState.showReminderDateModal) {
        ReminderDatePicker(reminderDate: $uiState.reminderDate)
      }
      .loading($uiState.loadingState, showAlert: $uiState.showAlert)
      .background(Color.Background.primary)
      .navigationTitle("新規作成")
      .navigationBarTitleDisplayMode(.inline)
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
            for task in tasks() {
              let query: Query.NormalTask = .perDog(uid: task.ownerId, dogId: task.dogId)
              try await db.set(task, collectionReference: query.collection())
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

private extension CreateTaskPage {
  func tasks() -> [NormalTask] {
    uiState.selectedDogs.map { dog in
      NormalTask(
        content: uiState.title,
        complete: false,
        dogId: dog.id!,
        expiredDate: .init(date: uiState.expiredDate),
        memo: uiState.memo,
        ownerId: uiState.ownerId,
        priority: .medium, // TODO: ここはUIで提供すること
        reminderDate: uiState.reminderDate.map { .init(date: $0.date(uiState.expiredDate)) }
      )
    }
  }
}

struct CreateTaskPage_Previews: PreviewProvider {
  static var previews: some View {
    CreateTaskPage()
  }
}
