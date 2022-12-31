import SwiftUI

/// Paging image.
public struct ImagePager: View {
  private let images: [UIImage]

  public init(images: [UIImage]) {
    self.images = images
  }

  public var body: some View {
    if images.isEmpty {
      Rectangle()
        .frame(maxWidth: .infinity)
    } else {
      TabView {
        ForEach(images, id: \.self) { image in
          Image(uiImage: images.first!)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
  }
}
