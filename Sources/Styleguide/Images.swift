import SwiftUI

// MARK: - Bundle images

public extension Image {
  static let bell = Self(systemName: "bell")
  static let booksVertical = Self(systemName: "books.vertical")
  static let calendar = Self(systemName: "calendar")
  static let cameraFill = Self(systemName: "camera.fill")
  static let checkList = Self(systemName: "checklist")
  static let chevronForward = Self(systemName: "chevron.forward")
  static let clock = Self(systemName: "clock")
  static let clockArrowCirclePath = Self(systemName: "clock.arrow.2.circlepath")
  static let checkmark = Self(systemName: "checkmark")
  static let checkmarkCircle = Self(systemName: "checkmark.circle")
  static let checkmarkCircleFill = Self(systemName: "checkmark.circle.fill")
  static let chevronBack = Self(systemName: "chevron.backward")
  static let circle = Self(systemName: "circle")
  static let ellipsisCircle = Self(systemName: "ellipsis.circle")
  static let eye = Self(systemName: "eye")
  static let eyeSlash = Self(systemName: "eye.slash")
  static let exclamationmarkCircleFill = Self(systemName: "exclamationmark.circle.fill")
  static let exclamationmarkTriangleFill = Self(systemName: "exclamationmark.triangle.fill")
  static let infoCircle = Self(systemName: "info.circle")
  static let listDash = Self(systemName: "list.dash")
  static let person = Self(systemName: "person")
  static let photo = Self(systemName: "photo")
  static let plusCircle = Self(systemName: "plus.circle")
  static let `repeat` = Self(systemName: "repeat")
  static let repeatCircle = Self(systemName: "repeat.circle")
  static let trash = Self(systemName: "trash")
}

// MARK: - Icon View

public struct Icon: View {
  private let image: UIImage?
  private let placeholder: Image?

  public init(
    image: UIImage?,
    placeholder: Image?
  ) {
    self.image = image
    self.placeholder = placeholder
  }

  public var body: some View {
    if let image {
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

        if let placeholder {
          placeholder
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
        }
      }
    }
  }
}
