import Core
import DataStore
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct TaskListPage<Router: Routing>: View where Router._Route == TaskRoute {
  private struct UiState {
    /// Flag for whether to push transition.
    var pushTransition: Bool = false
    /// Firestore query.
    var query: FirebaseFirestore.Query?
    /// Show only incompleted task if `true`
    var showOnlyIncompleted = true
    /// Flag for whether to modal transition.
    var showModal: Bool = false
    /// ID of the logged-in user.
    var uid: String?
  }

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()
  private let router: Router
  private let normalTaskQuery: Query.NormalTask?

  @State private var uiState = UiState()
  @State private var route: TaskRoute? {
    didSet {
      switch route {
      case .create:
        uiState.showModal = true
      case .detail:
        uiState.showModal = true
      case .none:
        break
      }
    }
  }

  @StateObject private var completeState: CompleteState = .init()

  public init(
    normalTaskQuery: Query.NormalTask?,
    router: Router
  ) {
    self.normalTaskQuery = normalTaskQuery
    self.router = router
  }

  private func status(of task: NormalTask) -> Bool {
    guard let id = task.id else { return task.complete }
    return completeState.status(of: id) ?? task.complete
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: NormalTask.fakes,
      query: uiState.query
    ) { data in
      // TODO: データが空の場合は、それ用のViewを表示すること
      ZStack(alignment: .top) {
        list(tasks: data)
        footer
      }
    } onFailure: { error in
      Text("error")
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        MenuItem(showOnlyIncompleted: $uiState.showOnlyIncompleted)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          route = .create
        } label: {
          Image.plusCircle
        }
      }
    }
    .navigate(
      router: router,
      route: route,
      isActive: .constant(false),
      isPresented: $uiState.showModal,
      onDismiss: nil
    )
    .onChange(of: uiState.showOnlyIncompleted) { value in
      Task { uiState.query = normalTaskQuery?.query(incompletedOnly: value) }
    }
    .task { uiState.uid = await authenticator.user()?.uid ?? "" }
    .onAppear {
      if uiState.query == nil {
        uiState.query = normalTaskQuery?.query(incompletedOnly: true)
      }
    }
  }

  func list(tasks: [NormalTask]) -> some View {
    List {
      ForEach(tasks) { task in
        TaskListItemView(task: task, complete: status(of: task)) { new in
          updateCompleteState(original: task, updated: new)
        }
        .padding(.trailing, Padding.small)
        .swipeActions(edge: .trailing) {
          Button {
            route = .detail(task)
          } label: {
            Text("詳細")
          }
        }
      }
    }
  }

  var footer: some View {
    VStack {
      Spacer()
      if !completeState.completes.isEmpty {
        Button {
          Task {
            await completeState.save()
          }
        } label: {
          Text("完了")
        }
        .buttonStyle(SmallButtonStyle())
        .padding(.bottom, Padding.small)
      }
    }
  }
}

private extension TaskListPage {
  /// Update task completion status.
  /// - Parameters:
  ///   - original: Task before completion status update .
  ///   - updated: Task after completion status update.
  func updateCompleteState(original: NormalTask, updated: NormalTask) {
    guard let id = original.id else { return }
    if original.complete && !completeState.contains(id) {
      Task {
        try? await completeState.toIncomplete(original)
      }
    } else {
      withAnimation {
        completeState.update(id, task: updated)
      }
    }
  }
}
