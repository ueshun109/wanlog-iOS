import Core
import FirebaseClient
import SharedModels

public enum DogRoute: Route {
  case createFirst
  case detail(dog: Dog)
}

public enum DogCreateRoute: Route {
  case createSecond(state: DogState)
}

public enum DogDetailRoute: Route {
  case tasks(Query.Todo?)
}
