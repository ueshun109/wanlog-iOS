import SwiftUI

public extension Color {
  struct Blue {
    public static let primary = Color("Blue/Primary", bundle: .module)
    public static let secondary = Color("Blue/Secondary", bundle: .module)
    public static let tertiary = Color("Blue/Tertiary", bundle: .module)
  }

  struct Fill {
    public static let primary = Color("Fill/Primary", bundle: .module)
    public static let secondary = Color("Fill/Secondary", bundle: .module)
    public static let tertiary = Color("Fill/Tertiary", bundle: .module)
    public static let quaternary = Color("Fill/Quaternary", bundle: .module)
  }

  struct Label {
    public static let primary = Color("Label/Primary", bundle: .module)
    public static let secondary = Color("Label/Secondary", bundle: .module)
    public static let tertiary = Color("Label/Tertiary", bundle: .module)
    public static let quaternary = Color("Label/Quaternary", bundle: .module)
  }
}
