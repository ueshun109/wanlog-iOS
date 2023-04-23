import Core
import SharedModels

public enum TodoRoute: Route {
  case create
  case detail(Todo)
}
