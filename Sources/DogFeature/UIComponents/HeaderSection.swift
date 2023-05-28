import SwiftUI

@ViewBuilder
func header(image: UIImage?) -> some View {
  if let image = image {
    Image(uiImage: image)
      .resizable()
      .scaledToFill()
      .frame(width: 100, height: 100)
      .clipShape(Circle())
  } else {
    ZStack {
      Circle()
        .fill(Color.Background.secondary)
        .frame(width: 100, height: 100)

      Image.person
        .resizable()
        .scaledToFit()
        .frame(width: 60, height: 60)
    }
  }
}
