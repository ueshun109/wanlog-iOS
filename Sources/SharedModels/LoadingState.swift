public enum LoadingState<T: Equatable>: Equatable {
  case idle(skeleton: T)
  case loading(skeleton: T)
  case loaded(data: T)
  case failed(error: LoadingError)
}

public enum Loading {
  case idle
  case loading
  case loaded
  case failed(error: LoadingError)
}
