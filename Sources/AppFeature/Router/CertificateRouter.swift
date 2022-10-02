import CertifiateFeature
import Core
import SwiftUI

struct CertificateRouter: Routing {
  @ViewBuilder
  func view(for route: CertificateRoute) -> some View {
    switch route {
    case .create:
      NavigationView {
        CreateCertificatePage()
      }
    }
  }
}
