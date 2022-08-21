import Core
import SharedModels

public enum DogRoute: Route, Equatable {
  case create
  case detail(dog: Dog)
}
