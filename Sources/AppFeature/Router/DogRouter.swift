import Core
import DogFeature
import SwiftUI

struct DogRouter: Routing {
  @ViewBuilder
  func view(for route: DogRoute) -> some View {
    switch route {
    case .create:
      CreateDogPage()
    case .detail(let dog):
      DogDetailPage(dog: dog)
    }
  }
}
