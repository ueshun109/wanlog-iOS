import SharedModels
import SwiftUI

public struct DogDetailPage: View {
  let dog: Dog

  public init(dog: Dog) {
    self.dog = dog
  }

  public var body: some View {
    Text(dog.name)
  }
}
