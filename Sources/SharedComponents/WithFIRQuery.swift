import Combine
import Core
import FirebaseClient
import SharedModels
import SwiftUI

/// WithFIRQuery is a component that determines the displayed content according to the load status.
public struct WithFIRQuery<T, Success: View, Failure: View>: View where T: Decodable, T: Equatable {
  @State private var loadingState: LoadingState<[T]>
  @State private var listenTask: Task<Void, Never>?
  private let db = Firestore.firestore()
  private let query: FirebaseFirestore.Query?
  private let onSuccess: ([T]) -> Success
  private let onFailure: (LoadingError) -> Failure

  public init(
    skeleton: [T],
    query: FirebaseFirestore.Query?,
    @ViewBuilder onSuccess: @escaping ([T]) -> Success,
    @ViewBuilder onFailure: @escaping (LoadingError) -> Failure
  ) {
    self.loadingState = .idle(skeleton: skeleton)
    self.query = query
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
    do {
      for try await data in db.listen(query, type: T.self) {
        logger.debug(message: data)
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
