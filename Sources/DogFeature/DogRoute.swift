import Core
import FirebaseFirestore
import SharedModels

public enum DogRoute: Route, Equatable {
  case create
  case detail(dog: Dog)
}

public enum DogDetailRoute: Route {
  case schedules(Query?)
}
