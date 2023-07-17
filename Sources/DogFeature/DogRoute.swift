import Core
import FirebaseClient
import SharedModels

public enum DogRoute: Route {
  case createFirst(dismiss: (() -> Void)?)
  case detail(dog: Dog)
}

public enum DogCreateRoute: Route {
  case createSecond(state: DogCreateFlow)
}

public enum DogDetailRoute: Route {
  case tasks(Query.Todo?)
}
