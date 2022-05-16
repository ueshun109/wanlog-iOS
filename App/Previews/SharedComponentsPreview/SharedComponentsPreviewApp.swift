import SharedComponents
import SwiftUI

@main
struct SharedComponentsPreviewApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        VStack {
          NavigationLink(
            "InputForm",
            destination: InputForm(text: .constant(""), placeholder: "placeholder", keyboardType: .emailAddress).padding()
          )
        }
      }
    }
  }
}
