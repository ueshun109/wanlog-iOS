import Core
import SharedModels

public enum CertificateRoute: Route {
  case create
  case detail(certificate: Certificate)
}
