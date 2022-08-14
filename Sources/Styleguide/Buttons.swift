import SwiftUI

public struct BackButton: View {
  var callback: () -> Void

  public init(callback: @escaping () -> Void) {
    self.callback = callback
  }

  public var body: some View {
    Button {
      callback()
    } label: {
      HStack(spacing: Padding.xSmall) {
        Image.chevronBack

        Text("戻る")
          .fontWithLineHeight(font: .hiraginoSans(.footnote))
      }
      .foregroundColor(.black)
    }
  }
}

// MARK: - EnterButton

public struct EnterButton: View {
  public enum IconPosition {
    case leading
    case trailing
  }

  private let title: String
  private let icon: Image?
  private let iconPosition: IconPosition?
  private let callback: () -> Void

  public init(
    title: String,
    icon: Image? = nil,
    iconPosition: IconPosition? = nil,
    callback: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.iconPosition = iconPosition
    self.callback = callback
  }

  public var body: some View {
    Button {
      callback()
    } label: {
      HStack {
        Spacer()
        switch iconPosition {
        case .some(.leading):
          HStack(spacing: Padding.xSmall) {
            icon
            Text(title)
              .fontWithLineHeight(font: .sfPro(.subheadline))
          }
        case .some(.trailing):
          HStack(spacing: Padding.xSmall) {
            Text(title)
              .fontWithLineHeight(font: .sfPro(.subheadline))
            icon
          }
        case .none:
          Text(title)
            .fontWithLineHeight(font: .sfPro(.subheadline))
        }
        Spacer()
      }
      .frame(height: 44)
    }
  }
}

public struct EnterButtonStylePrimary: ButtonStyle {
  private let backgroundColor: Color

  public init(backgroundColor: Color ) {
    self.backgroundColor = backgroundColor
  }

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .fontWithLineHeight(font: .hiraginoSans(.subheadline))
      .foregroundColor(.white)
      .background(backgroundColor)
      .cornerRadius(8)
  }
}

public struct EnterButtonStyleSecondary: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .fontWithLineHeight(font: .hiraginoSans(.subheadline))
      .foregroundColor(.white)
      .cornerRadius(64)
  }
}

public struct EnterButtonStyleThirdly: ButtonStyle {
  private let foregroundColor: Color
  private let borderColor: Color

  public init(
    foregroundColor: Color,
    borderColor: Color
  ) {
    self.foregroundColor = foregroundColor
    self.borderColor = borderColor
  }

  public func makeBody(configuration: Configuration) -> some View {
    ZStack {
      configuration.label
        .fontWithLineHeight(font: .hiraginoSans(.subheadline))
        .foregroundColor(foregroundColor)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(borderColor, lineWidth: 1)
        )
    }
  }
}

public struct SmallButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.subheadline)
      .foregroundColor(.white)
      .padding(.vertical, Padding.xSmall)
      .padding(.horizontal, Padding.medium)
      .background(
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(.black)
      )
      .opacity(configuration.isPressed ? 0.9 : 1)
  }
}

// MARK: - CircleButton

public struct CircleButton: View {
  @State private var image: Image
  @Binding private var opacity: CGFloat
  private let onTap: () -> Void

  public init(
    image: Image,
    opacity: Binding<CGFloat>? = nil,
    onTap: @escaping () -> Void
  ) {
    self.image = image
    self._opacity = opacity ?? .constant(1)
    self.onTap = onTap
  }

  public var body: some View {
    Button {
      onTap()
    } label: {
      image
        .resizable()
        .frame(width: 16, height: 16)
        .foregroundColor(Color.Label.secondary)
        .padding(8)
        .background(Color.white.opacity(self.opacity))
        .clipShape(Circle())
    }
  }
}

// MARK: - Previews

struct RectangleButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      EnterButton(
        title: "検索する",
        icon: .person,
        iconPosition: .leading
      ) {

      }
      .buttonStyle(EnterButtonStylePrimary(backgroundColor: Color.Blue.primary))

      EnterButton(
        title: "検索する",
        icon: .person,
        iconPosition: .trailing
      ) {

      }
      .buttonStyle(EnterButtonStylePrimary(backgroundColor: Color.Blue.secondary))

      EnterButton(
        title: "検索する"
      ) {

      }
      .buttonStyle(EnterButtonStylePrimary(backgroundColor: Color.Blue.tertiary))
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, Padding.xLarge)
  }
}

struct RectangleButtonThirdly_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      EnterButton(
        title: "検索する",
        icon: .person,
        iconPosition: .leading
      ) {

      }
      .buttonStyle(EnterButtonStyleThirdly(
        foregroundColor: Color.Blue.tertiary,
        borderColor: Color.Label.secondary
      ))

      EnterButton(
        title: "検索する",
        icon: .person,
        iconPosition: .trailing
      ) {

      }
      .buttonStyle(EnterButtonStyleThirdly(
        foregroundColor: Color.Blue.primary,
        borderColor: Color.Label.secondary
      ))

      EnterButton(
        title: "検索する"
      ) {

      }
      .buttonStyle(EnterButtonStyleThirdly(
        foregroundColor: Color.Blue.tertiary,
        borderColor: Color.Label.secondary
      ))
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, Padding.xLarge)
  }
}
