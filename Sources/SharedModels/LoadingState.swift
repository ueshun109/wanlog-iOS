public enum LoadingState: Equatable {
  case idle
  case loading
  case loaded
  case failed(error: LoadingError)
}
