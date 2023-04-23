import Core
import FirebaseClient
import SharedModels

public enum DogRoute: Route, Equatable {
  case create
  case detail(dog: Dog)
}

public enum DogDetailRoute: Route {
  case tasks(Query.Todo?)
}
