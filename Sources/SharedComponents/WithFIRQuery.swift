import Combine
import Core
import FirebaseClient
import SharedModels
import SwiftUI

/// WithFIRQuery is a component that determines the displayed content according to the load status.
public struct WithFIRQuery<T, Success: View, Failure: View>: View where T: Decodable, T: Equatable {
  @Binding private var nextPage: Int
  @Binding private var hasMore: Bool
  @State private var loadingState: LoadingState<[T]>
  @State private var listenTask: Task<Void, Never>?
  private let basePageSize: Int
  private let db = Firestore.firestore()
  private let query: FirebaseFirestore.Query?
  private let skelton: [T]
  private let onSuccess: ([T]) -> Success
  private let onFailure: (LoadingError) -> Failure

  public init(
    skeleton: [T],
    query: FirebaseFirestore.Query?,
    nextPage: Binding<Int> = .constant(0),
    hasMore: Binding<Bool> = .constant(false),
    basePageSize: Int = 100,
    @ViewBuilder onSuccess: @escaping ([T]) -> Success,
    @ViewBuilder onFailure: @escaping (LoadingError) -> Failure
  ) {
    self._nextPage = nextPage
    self._hasMore = hasMore
    self.loadingState = .idle(skeleton: skeleton)
    self.query = query
    self.basePageSize = basePageSize
    self.skelton = skeleton
    self.onSuccess = onSuccess
    self.onFailure = onFailure
  }

  public var body: some View {
    ZStack {
      if let query = query {
        Group {
          switch loadingState {
          case .idle(let skeleton), .loading(let skeleton):
            onSuccess(skeleton)
              .redacted(reason: .placeholder)
              .transition(.opacity)
          case .loaded(let data):
            onSuccess(data)
              .redacted(reason: [])
              .transition(.opacity)
          case .failed(let error):
            onFailure(error)
              .transition(.opacity)
          }
        }
        .onChange(of: query) { new in
          if let listenTask = listenTask {
            listenTask.cancel()
          }
          listenTask = Task {
            await update(with: new)
          }
        }
        .onAppear {
          guard listenTask == nil else { return }
          listenTask = Task { await update(with: query) }
        }
      }
    }
    .animation(.default, value: query)
  }

  private func update(with query: FirebaseFirestore.Query) async {
    let firstLoading = nextPage == 1
    if firstLoading {
      self.loadingState = .loading(skeleton: skelton)
      // This is a workaround for additional loading when display conditions change.
      try! await Task.sleep(nanoseconds: 1_000_000_000)
    }
    do {
      for try await data in db.listen(query, type: T.self) {
        hasMore = basePageSize * nextPage == data.count
        if hasMore { nextPage += 1 }
        withAnimation {
          self.loadingState = .loaded(data: data)
        }
      }
    } catch let loadingError as LoadingError {
      logger.error(message: loadingError)
      withAnimation {
        self.loadingState = .failed(error: loadingError)
      }
    } catch {
      logger.error(message: error)
      let loadingError = LoadingError(errorDescription: error.localizedDescription)
      withAnimation {
        self.loadingState = .failed(error: loadingError)
      }
    }
  }
}
