import Core
import DataStore
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct TodoListPage<Router: Routing>: View where Router._Route == TodoRoute {
  private struct UiState {
    /// Dog images.
    var dogImages: [String?: UIImage] = [:]
    /// Pagination page.
    var nextPage = 1
    /// Whether has next page.
    var hasMore = false
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
  private let getDogList = DogUsecase.getDogList
  private let basePageSize = 100
  private let router: Router
  private let todoQuery: Query.Todo?
  private let storage: Storage = .storage()

  @State private var uiState = UiState()
  @State private var route: TodoRoute? {
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
    todoQuery: Query.Todo?,
    router: Router
  ) {
    self.todoQuery = todoQuery
    self.router = router
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: Todo.fakes,
      query: uiState.query,
      nextPage: $uiState.nextPage,
      hasMore: $uiState.hasMore,
      basePageSize: basePageSize
    ) { data in
      // TODO: データが空の場合は、それ用のViewを表示すること
      ZStack(alignment: .top) {
        list(todos: data)
        doneButton
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
      uiState.hasMore = false
      uiState.nextPage = 1
      Task {
        uiState.query = todoQuery?.query(incompletedOnly: value, limit: basePageSize)
      }
    }
    .task {
      guard uiState.query == nil else { return }
      uiState.query = todoQuery?.query(incompletedOnly: true, limit: basePageSize)
      uiState.uid = await authenticator.user()?.uid ?? ""
      do {
        let dogs = try await getDogList()
        for dog in dogs {
          guard let iconRef = dog.iconRef else { continue }
          let data = try await storage.reference(withPath: iconRef).get()
          uiState.dogImages[dog.id] = UIImage(data: data)
        }
      } catch {
      }
    }
  }

  /// 📖 View to display a list of Todo.
  func list(todos: [Todo]) -> some View {
    var _todos = todos
    let lastItem = todos.last
    let completed = uiState.showOnlyIncompleted ? [] : _todos.removedCompleted()
    let expired = _todos.removedExpired()
    let high = _todos.filter { $0.shouldAttention() }
    let normal = _todos.filter { !$0.shouldAttention() }
    return List {
      if !uiState.showOnlyIncompleted {
        completedSection(todos: completed, lastItem: lastItem)
      }
      expiredSection(todos: expired, lastItem: lastItem)
      highPrioritySection(todos: high, lastItem: lastItem)
      normalPrioritySection(todos: normal, lastItem: lastItem)
    }
    .listStyle(.insetGrouped)
  }

  @ViewBuilder
  /// ✅ A section that represents a list of completed todo's.
  func completedSection(todos: [Todo], lastItem: Todo?) -> some View {
    if todos.isEmpty {
      EmptyView()
    } else {
      Section {
        contents(todos: todos, lastItem: lastItem)
      } header: {
        header(section: .completed)
      } footer: {
        footer(showProgress: todos.last == lastItem && uiState.hasMore)
      }
    }
  }

  @ViewBuilder
  /// 🔴 A section that represents a list of expired todo's.
  func expiredSection(todos: [Todo], lastItem: Todo?) -> some View {
    if todos.isEmpty {
      EmptyView()
    } else {
      Section {
        contents(todos: todos, lastItem: lastItem)
      } header: {
        header(section: .expired)
      } footer: {
        footer(showProgress: todos.last == lastItem && uiState.hasMore)
      }
    }
  }

  @ViewBuilder
  /// 🟡 A section that represents a list of high priority todo's.
  func highPrioritySection(todos: [Todo], lastItem: Todo?) -> some View {
    if todos.isEmpty {
      EmptyView()
    } else {
      Section {
        contents(todos: todos, lastItem: lastItem)
      } header: {
        header(section: .highPriority)
      } footer: {
        footer(showProgress: todos.last == lastItem && uiState.hasMore)
      }
    }
  }

  @ViewBuilder
  /// 🟢 A section that represents a list of middle or low priority todo's.
  func normalPrioritySection(todos: [Todo], lastItem: Todo?) -> some View {
    if todos.isEmpty {
      EmptyView()
    } else {
      Section {
        contents(todos: todos, lastItem: lastItem)
      } header: {
        header(section: .normal)
      } footer: {
        footer(showProgress: todos.last == lastItem && uiState.hasMore)
      }
    }
  }

  /// 📄 List items.
  func contents(todos: [Todo], lastItem: Todo?) -> some View {
    ForEach(todos) { todo in
      // If the TODO has already been completed, the completed status is used; if not, the tentative status is used.
      let complete = todo.complete ? todo.complete : completeState.status(of: todo.id)
      TaskListItemView(
        complete: complete,
        dogImage: uiState.dogImages[todo.dogId],
        todo: todo
      ) { new in
        Task {
          try? await completeState.update(original: todo, updated: new)
        }
      }
      .padding(.trailing, Padding.small)
      .swipeActions(edge: .trailing) {
        Button {
          route = .detail(todo)
        } label: {
          Text("詳細")
        }
      }
      .task {
        let displayLastItemInSection = todos.last == todo
        let displayLastItemInAll = lastItem == todo
        guard displayLastItemInSection, displayLastItemInAll, uiState.hasMore else {
          logger.debug(message: "additional: \(displayLastItemInSection), \(displayLastItemInAll), \(uiState.hasMore)")
          return
        }
        uiState.query = todoQuery?.query(
          incompletedOnly: uiState.showOnlyIncompleted,
          limit: basePageSize * uiState.nextPage
        )
      }
    }
  }

  /// ⛑️ Header
  func header(section: SectionType) -> some View {
    HStack {
      section.image
      Text(section.title)
        .fontWithLineHeight(font: .hiraginoSans(.footnote))
    }
    .foregroundColor(section.color)
  }

  /// 🪝Footer
  func footer(showProgress: Bool) -> some View {
    HStack {
      Spacer()
      if showProgress {
        ProgressView()
      }
      Spacer()
    }
  }

  /// 💯 Done button
  var doneButton: some View {
    VStack {
      Spacer()
      if !completeState.completes.isEmpty {
        Button {
          Task {
            try? await completeState.toComplete()
          }
        } label: {
          Text("完了")
        }
        .buttonStyle(SmallButtonStyle())
        .padding(.bottom, Padding.small)
      }
    }
    .animation(.default, value: completeState.completes)
  }
}

extension TodoListPage {
  enum SectionType {
    case expired
    case highPriority
    case normal
    case completed

    var title: String {
      switch self {
      case .expired:
        return "期限が切れているタスク"
      case .highPriority:
        return "重要度が高く期日が近いタスク"
      case .normal:
        return "未完了のタスク"
      case .completed:
        return "完了済みのタスク"
      }
    }

    var image: Image {
      switch self {
      case .completed:
        return Image.checkmarkCircleFill
      case .expired, .highPriority:
        return Image.exclamationmarkTriangleFill
      case .normal:
        return Image.checkList
      }
    }

    var color: Color {
      switch self {
      case .completed:
        return Color.green
      case .expired:
        return Color.Red.primary
      case .highPriority:
        return Color.Yellow.primary
      case .normal:
        return Color.Label.primary
      }
    }
  }
}
