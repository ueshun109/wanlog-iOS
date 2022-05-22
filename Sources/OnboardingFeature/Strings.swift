import SwiftUI

enum Strings: String {
  case mailAddress = "MailAddress"
  case password = "Password"
  case signIn = "SignIn"
  case signUp = "SignUp"
  case signUpPros = "SignUpPros"
  case skip = "Skip"

  var key: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }

  var localized: String {
    NSLocalizedString(self.rawValue, bundle: .module, comment: "")
  }

  func localized<T: CVarArg>(with arg: T) -> String {
    String(format: NSLocalizedString(self.rawValue, bundle: .module, comment: ""), arg)
  }
}
