import Core
import DataStore
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct SchedulePage<Router: Routing>: View where Router._Route == ScheduleRoute {
  private struct UiState {
    /// Flag for whether to push transition.
    var pushTransition: Bool = false
    /// Firestore query.
    var query: Query?
    /// Show only incompleted task if `true`
    var showOnlyIncompleted = true
    /// Flag for whether to modal transition.
    var showModal: Bool = false
    /// ID of the logged-in user.
    var uid: String?
  }

  private let db = Firestore.firestore()
  private let authenticator: Authenticator = .live
  private let router: Router
  private let tmpQuery: Query?

  @State private var uiState = UiState()
  @State private var route: ScheduleRoute? {
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
    query: Query?,
    router: Router
  ) {
    self.tmpQuery = query
    self.router = router
  }

  private func status(of schedule: Schedule) -> Bool {
    guard let id = schedule.id else { return schedule.complete }
    return completeState.status(of: id) ?? schedule.complete
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: Schedule.skeleton,
      query: uiState.query
    ) { data in
      // TODO: データが空の場合は、それ用のViewを表示すること
      ZStack {
        List {
          ForEach(data) { schedule in
            ScheduleItem(
              schedule: schedule,
              complete: status(of: schedule)
            ) { new in
              updateCompleteState(original: schedule, updated: new)
            }
            .swipeActions(edge: .trailing) {
              Button {
                route = .detail(schedule)
              } label: {
                Text("詳細")
              }
            }
          }
        }

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
      Task {
        uiState.query = Query.schedules(uid: uiState.uid!, incompletedOnly: value)
      }
    }
    .task {
      uiState.uid = await authenticator.user()?.uid ?? ""
    }
    .onAppear {
      if uiState.query == nil {
        uiState.query = tmpQuery
      }
    }
  }

  /// Menu item displayed on the toolbar.
  private struct MenuItem: View {
    @Binding var showOnlyIncompleted: Bool

    var body: some View {
      Menu {
        Button {
          showOnlyIncompleted.toggle()
        } label: {
          if showOnlyIncompleted {
            HStack {
              Text("完了済みを表示")
              Spacer()
              Image.eye
            }
          } else {
            HStack {
              Text("完了済みを非表示")
              Spacer()
              Image.eyeSlash
            }
          }
        }
      } label: {
        Image.ellipsisCircle
      }
    }
  }

  /// Schedule item view.
  private struct ScheduleItem: View {
    var schedule: Schedule
    var onChange: (Schedule) -> Void
    private let complete: Bool

    init(
      schedule: Schedule,
      complete: Bool,
      onChange: @escaping (Schedule) -> Void
    ) {
      self.schedule = schedule
      self.complete = complete
      self.onChange = onChange
    }

    var body: some View {
      HStack {
        VStack(alignment: .leading, spacing: 12) {
          HStack(spacing: Padding.xSmall) {
            CheckBox(checked: complete) { status in
              var new = schedule
              new.complete = status
              onChange(new)
            }

            Text(schedule.content)
              .font(.headline)
          }

          HStack(spacing: Padding.xSmall) {
            Image.clock
              .resizable()
              .frame(width: 16, height: 16)
            Text(toString(schedule.date.dateValue(), formatter: .yearAndMonthAndDayWithSlash))
              .font(.subheadline)
          }
        }

        Spacer()

        Image.person
          .resizable()
          .frame(width: 24, height: 24)
      }
      .padding(.trailing, Padding.small)
    }
  }
}

private extension SchedulePage {
  /// Update schedule completion status.
  /// - Parameters:
  ///   - original: Schedule before completion status update .
  ///   - updated: Schedule after completion status update.
  func updateCompleteState(original: Schedule, updated: Schedule) {
    guard let id = original.id else { return }
    if original.complete && !completeState.contains(id) {
      Task {
        try? await completeState.toIncomplete(original)
      }
    } else {
      withAnimation {
        completeState.update(id, schedule: updated)
      }
    }
  }
}
