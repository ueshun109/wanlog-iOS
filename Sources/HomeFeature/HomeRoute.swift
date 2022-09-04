import Core
import FirebaseFirestore

public enum HomeRoute: Route {
  case schedule(Query?)
  case dogList
  case history
}
