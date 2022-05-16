import SwiftUI

public struct WanlogFont {
  public var font: UIFont
  public var lineHeight: CGFloat

  public init(
    font: UIFont,
    lineHeight: CGFloat
  ) {
    self.font = font
    self.lineHeight = lineHeight
  }

  private static let hiraginoSans = "HiraginoSans-W3"

  public static func hiraginoSans(_ font: HiraginoSans, bold: Bool = false) -> WanlogFont {
    if bold {
      return .init(font: UIFont(name: hiraginoSans, size: font.size)!.bold(), lineHeight: font.lineHeight)
    } else {
      return .init(font: UIFont(name: hiraginoSans, size: font.size)!, lineHeight: font.lineHeight)
    }
  }

  public static func sfPro(_ font: SFPro, bold: Bool = false) -> WanlogFont {
    if bold {
      return .init(font: font.font.bold(), lineHeight: font.lineHeight)
    } else {
      return .init(font: font.font, lineHeight: font.lineHeight)
    }
  }

  public enum HiraginoSans {
    case caption2
    case caption1
    case footnote
    case subheadline
    case callout
    case body
    case headline
    case title3
    case title2
    case title1
    case largeTitle

    public var lineHeight: CGFloat {
      switch self {
      case .caption2: return 13
      case .caption1: return 16
      case .footnote: return 18
      case .subheadline: return 20
      case .callout: return 21
      case .body: return 22
      case .headline: return 22
      case .title3: return 24
      case .title2: return 28
      case .title1: return 34
      case .largeTitle: return 41
      }
    }

    public var size: CGFloat {
      switch self {
      case .caption2: return 11
      case .caption1: return 12
      case .footnote: return 13
      case .subheadline: return 15
      case .callout: return 16
      case .body: return 17
      case .headline: return 17
      case .title3: return 20
      case .title2: return 22
      case .title1: return 28
      case .largeTitle: return 34
      }
    }
  }

  public enum SFPro {
    case tiny2
    case caption2
    case caption1
    case footnote
    case subheadline
    case callout
    case body
    case headline
    case title3
    case title2
    case title1
    case largeTitle

    public var font: UIFont {
      switch self {
      case .tiny2: return .systemFont(ofSize: 9)
      case .caption2: return .preferredFont(forTextStyle: .caption2)
      case .caption1: return .preferredFont(forTextStyle: .caption1)
      case .footnote: return .preferredFont(forTextStyle: .footnote)
      case .subheadline: return .preferredFont(forTextStyle: .subheadline)
      case .callout: return .preferredFont(forTextStyle: .callout)
      case .body: return .preferredFont(forTextStyle: .body)
      case .headline: return .preferredFont(forTextStyle: .headline)
      case .title3: return .preferredFont(forTextStyle: .title3)
      case .title2: return .preferredFont(forTextStyle: .title2)
      case .title1: return .preferredFont(forTextStyle: .title1)
      case .largeTitle: return .preferredFont(forTextStyle: .largeTitle)
      }
    }

    public var lineHeight: CGFloat {
      switch self {
      case .tiny2: return 10
      case .caption2: return 13
      case .caption1: return 16
      case .footnote: return 18
      case .subheadline: return 20
      case .callout: return 21
      case .body: return 17
      case .headline: return 17
      case .title3: return 24
      case .title2: return 28
      case .title1: return 34
      case .largeTitle: return 41
      }
    }
  }
}

public struct FontWithLineHeight: ViewModifier {
  private let wanlogFont: WanlogFont

  public init(_ wanlogFont: WanlogFont) {
    self.wanlogFont = wanlogFont
  }

  public func body(content: Content) -> some View {
    content
      .font(Font(wanlogFont.font))
      .lineSpacing(wanlogFont.lineHeight - wanlogFont.font.lineHeight)
  }
}

public extension View {
  func fontWithLineHeight(font: WanlogFont) -> some View {
    ModifiedContent(content: self, modifier: FontWithLineHeight(font))
  }
}

extension UIFont {
  func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    let descriptor = fontDescriptor.withSymbolicTraits(traits)
    return UIFont(descriptor: descriptor!, size: 0)  // サイズをそのまま維持するためにsizeを0としている
  }

  func bold() -> UIFont {
    return withTraits(traits: .traitBold)
  }
}

#if DEBUG
  struct Font_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        VStack(alignment: .leading, spacing: 8) {
          Group {
            Text("Default / Regular / Caption2")
              .fontWithLineHeight(font: .sfPro(.caption2))
            Text("Default / Regular / Caption1")
              .fontWithLineHeight(font: .sfPro(.caption1))
            Text("Default / Regular / Footnote")
              .fontWithLineHeight(font: .sfPro(.footnote))
            Text("Default / Regular / Subheadline")
              .fontWithLineHeight(font: .sfPro(.subheadline))
            Text("Default / Regular / Callout")
              .fontWithLineHeight(font: .sfPro(.callout))
            Text("Default / Regular / Body")
              .fontWithLineHeight(font: .sfPro(.body))
            Text("Default / Regular / Headline")
              .fontWithLineHeight(font: .sfPro(.headline, bold: true))
          }
          Group {
            Text("Default / Regular / Title3")
              .fontWithLineHeight(font: .sfPro(.title3))
            Text("Default / Regular / Title2")
              .fontWithLineHeight(font: .sfPro(.title2))
            Text("Default / Regular / Title1")
              .fontWithLineHeight(font: .sfPro(.title1))
            Text("Default / Regular / LargeTitle")
              .fontWithLineHeight(font: .sfPro(.largeTitle))
          }
          Spacer()
        }
        .navigationTitle(Text("EN: SF Pro Text"))
      }

      NavigationView {
        VStack(alignment: .leading, spacing: 8) {
          Group {
            Text("Default / Regular / Caption2")
              .fontWithLineHeight(font: .hiraginoSans(.caption2))
            Text("Default / Regular / Caption1")
              .fontWithLineHeight(font: .hiraginoSans(.caption1))
            Text("Default / Regular / Footnote")
              .fontWithLineHeight(font: .hiraginoSans(.footnote))
            Text("Default / Regular / Subheadline")
              .fontWithLineHeight(font: .hiraginoSans(.subheadline))
            Text("Default / Regular / Callout")
              .fontWithLineHeight(font: .hiraginoSans(.callout))
            Text("Default / Regular / Body")
              .fontWithLineHeight(font: .hiraginoSans(.body))
            Text("Default / Regular / Headline")
              .fontWithLineHeight(font: .hiraginoSans(.headline, bold: true))
          }
          Group {
            Text("Default / Regular / Title3")
              .fontWithLineHeight(font: .hiraginoSans(.title3))
            Text("Default / Regular / Title2")
              .fontWithLineHeight(font: .hiraginoSans(.title2))
            Text("Default / Regular / Title1")
              .fontWithLineHeight(font: .hiraginoSans(.title1))
            Text("Default / Regular / LargeTitle")
              .fontWithLineHeight(font: .hiraginoSans(.largeTitle))
          }
          Spacer()
        }
        .navigationTitle(Text("JP: Hiragino"))
      }
    }
  }
#endif
