import Core
import FirebaseClient

public enum HomeRoute: Route {
  case taskList(Query.NormalTask?)
  case dogList
  case history(Query.Certificate?)
}
