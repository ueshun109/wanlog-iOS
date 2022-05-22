import SwiftUI

public struct HorizontalBorder: View {
  public init() {}

  public var body: some View {
    Rectangle()
      .frame(height: 0.5)
      .frame(maxWidth: .infinity)
      .foregroundColor(Color.Separator.thinBorder)
  }
}
