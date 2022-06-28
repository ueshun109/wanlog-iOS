import DataStore
import SharedModels
import SwiftUI

public struct SchedulePage: View {
  @StateObject private var userState: UserState = .init(authenticator: .live)
  @StateObject private var state: DogState = .init(authenticator: .live)

  public init() {}

  public var body: some View {
    List {
      ForEach(state.dogs) { dog in
        Text(dog.name)
      }
    }
    .task {
      await state.getDogs()
    }
  }
}
