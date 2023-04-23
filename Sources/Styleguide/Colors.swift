import SwiftUI

public extension Color {
  struct Background {
    public static let primary = Color("Background/Primary", bundle: .module)
    public static let secondary = Color("Background/Secondary", bundle: .module)
    public static let tertiary = Color("Background/Tertiary", bundle: .module)
  }

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

  struct Red {
    public static let primary = Color("Red/Primary", bundle: .module)
  }

  struct Yellow {
    public static let primary = Color("Yellow/Primary", bundle: .module)
  }

  struct Separator {
    public static let noTransparency = Color("Separator/NoTransparency", bundle: .module)
    public static let thinBorder = Color("Separator/ThinBorder", bundle: .module)
  }
}
