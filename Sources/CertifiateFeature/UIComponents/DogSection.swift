import SharedModels
import Styleguide
import SwiftUI

struct DogSection: View {
  @Binding var showDogsModal: Bool
  @FocusState var focused: Bool
  let dog: Dog?

  var body: some View {
    VStack {
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

          if let dog {
            Text(dog.name)
          } else {
            Text("ワンちゃんを選択してください")
          }

          Spacer()
        }
      }
    }
    .foregroundColor(Color.Label.primary)
    .padding(Padding.small)
    .background(Color.Background.secondary)
    .clipShape(
      RoundedRectangle(cornerRadius: 8)
    )
  }
}
