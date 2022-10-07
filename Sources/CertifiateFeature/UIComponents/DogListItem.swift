import SharedModels
import Styleguide
import SwiftUI

struct DogListItem: View {
  @Binding var selection: Dog?
  let dog: Dog

  var body: some View {
    Button {
      if let selection, selection == dog {
        self.selection = nil
      } else {
        selection = dog
      }
    } label: {
      HStack(spacing: Padding.xSmall) {
        if let selection = selection, selection.name == dog.name {
          Image.checkmarkCircleFill
            .foregroundColor(.blue)
        } else {
          Image.circle
            .foregroundColor(.gray)
        }

        Text(dog.name)
          .font(.body)
          .foregroundColor(Color.Label.primary)
      }
    }
  }
}
