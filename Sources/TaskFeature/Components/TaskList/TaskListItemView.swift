import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

/// Task item view for List.
struct TaskListItemView: View {
  let complete: Bool
  var dogImage: UIImage?
  var todo: Todo
  var onChange: (Todo) -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: Padding.xSmall) {
          CheckBox(checked: complete) { status in
            var new = todo
            new.complete = status
            onChange(new)
          }

          Text(todo.content)
            .font(.headline)
            .foregroundColor(Color.Label.primary)
        }

        HStack(spacing: Padding.xSmall) {
          Image.clock
            .resizable()
            .frame(width: 16, height: 16)
          Text(toString(todo.expiredDate.dateValue(), formatter: .yearAndMonthAndDayWithSlash))
            .font(.subheadline)
        }
      }

      Spacer()

      if let image = dogImage {
        Image(uiImage: image)
          .resizable()
          .frame(width: 32, height: 32)
          .scaledToFit()
          .clipShape(Circle())
      } else {
        Image.person
          .resizable()
          .frame(width: 24, height: 24)
      }

    }
    .padding(.trailing, Padding.small)
  }
}

struct TaskListItemView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      ForEach(Todo.fakes) { todo in
        TaskListItemView(
          complete: false,
          dogImage: nil,
          todo: todo
        ) { _ in }
      }
      .listRowBackground(Color.Background.tertiary)
    }
  }
}

