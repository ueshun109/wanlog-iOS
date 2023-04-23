import Core
import FirebaseClient

public enum HomeRoute: Route {
  case taskList(Query.Todo?)
  case dogList
  case history(Query.Certificate?)
}
