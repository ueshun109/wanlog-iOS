import Core
import SharedModels

public enum TaskRoute: Route {
  case create
  case detail(NormalTask)
}
