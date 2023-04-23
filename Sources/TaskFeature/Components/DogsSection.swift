import SharedModels
import Styleguide
import SwiftUI

struct DogsSection: View {
  @Binding var showDogsModal: Bool
  @FocusState var focused: Bool
  let dogs: Set<Dog>

  var body: some View {
    Section {
      Button {
        focused = false
        showDogsModal = true
      } label: {
        HStack {
          Image.person
            .frame(width: 16, height: 16)
            .foregroundColor(.white)
            .padding(6)
            .background(.blue)
            .cornerRadius(6)

          if dogs.isEmpty {
            Text("ワンちゃんを選択してください")
          } else {
            ForEach(Array(dogs)) { dog in
              Text(dog.name)
            }
          }

          Spacer()
        }
      }
    }
    .foregroundColor(Color.Label.primary)
  }
}
