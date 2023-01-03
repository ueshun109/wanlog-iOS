import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

/// Task item view for List.
struct TaskListItemView: View {
  var task: NormalTask
  var onChange: (NormalTask) -> Void
  private let complete: Bool

  init(
    task: NormalTask,
    complete: Bool,
    onChange: @escaping (NormalTask) -> Void
  ) {
    self.task = task
    self.complete = complete
    self.onChange = onChange
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: Padding.xSmall) {
          CheckBox(checked: complete) { status in
            var new = task
            new.complete = status
            onChange(new)
          }

          Text(task.content)
            .font(.headline)
        }

        HStack(spacing: Padding.xSmall) {
          Image.clock
            .resizable()
            .frame(width: 16, height: 16)
          Text(toString(task.expiredDate.dateValue(), formatter: .yearAndMonthAndDayWithSlash))
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

struct TaskListItemView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      ForEach(NormalTask.fakes) { task in
        TaskListItemView(
          task: task,
          complete: false
        ) { _ in }
      }
    }
  }
}

