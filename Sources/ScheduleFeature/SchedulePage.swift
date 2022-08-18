import Core
import DataStore
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct SchedulePage<Router: Routing>: View where Router._Route == ScheduleRoute {
  private let db = Firestore.firestore()
  private let authenticator: Authenticator = .live
  private let router: Router

  @State private var uid: String?
  @State private var query: Query?
  @State private var showModal: Bool = false
  @State private var pushTransition: Bool = false
  @State private var route: ScheduleRoute? = nil {
    didSet {
      switch route {
      case .create:
        showModal = true
      case .detail:
        showModal = true
      case .none:
        break
      }
    }
  }
  @StateObject private var completeState: CompleteState = .init()

  public init(router: Router) {
    self.router = router
  }

  private func status(of schedule: Schedule) -> Bool {
    guard let id = schedule.id else { return schedule.complete }
    return completeState.status(of: id) ?? schedule.complete
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: Schedule.skeleton,
      query: query
    ) { data in
      // TODO: データが空の場合は、それ用のViewを表示すること
      ZStack {
        List {
          ForEach(data) { schedule in
            ScheduleItem(
              schedule: schedule,
              complete: status(of: schedule)
            ) { new in
              if let id = schedule.id {
                withAnimation {
                  completeState.update(id, schedule: new)
                }
              }
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
      .toolbar {
        HStack {
          Button {
            // 作成ページに遷移する
            route = .create
          } label: {
            Image.plusCircle
          }
        }
      }
    } onFailure: { error in
      Text("error")
    }
    .navigate(
      router: router,
      route: route,
      isActive: .constant(false),
      isPresented: $showModal,
      onDismiss: nil
    )
    .task {
      self.uid = await authenticator.user()?.uid ?? ""
      self.query = Query.schedules(uid: uid!)
    }
  }
}

struct ScheduleItem: View {
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
