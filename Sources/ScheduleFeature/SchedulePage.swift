import DataStore
import SharedModels
import SharedComponents
import Styleguide
import SwiftUI

public struct SchedulePage: View {
  private let db = Firestore.firestore()
  private let authenticator: Authenticator = .live

  @State private var uid: String?
  @State private var query: Query?
  @StateObject private var completeState: CompleteState = .init()

  public init() {}

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
        }
      }
      .toolbar {
        Button {
          Task {
            await completeState.save()
          }
        } label: {
          Text("完了")
        }
        .disabled(completeState.completes.isEmpty)
      }
    } onFailure: { error in
      Text("error")
    }
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
  }
}
