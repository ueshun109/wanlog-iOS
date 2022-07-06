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

  @State private var schedules: [Schedule] = Schedule.skeleton

  public init() {}

  public var body: some View {
    WithFIRQuery(
      skeleton: schedules,
      query: query
    ) { data in
      List {
        ForEach(self.schedules) { schedule in
          ScheduleItem(schedule: schedule) { new in
            guard let index = self.schedules.firstIndex(of: schedule) else { return }
            withAnimation {
              schedules[index] = new
            }
          }
        }
      }
      .toolbar {
        Button {
        } label: {
          Text("完了")
        }
        .disabled(!contains(schedules))
      }
      .onAppear {
        self.schedules = data
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

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: Padding.xSmall) {
          CheckBox(checked: schedule.complete) { status in
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
