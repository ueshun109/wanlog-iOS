import Core
import FirebaseClient

public enum HomeRoute: Route {
  case schedule(Query.Schedule?)
  case dogList
  case history
}
