import Core
import FirebaseClient
import SharedModels
import SwiftUI

/// WithFIRQuery is a component that determines the displayed content according to the load status.
public struct WithFIRQuery<T, Success: View, Failure: View>: View where T: Decodable, T: Equatable {
  @State private var loadingState: LoadingState<[T]>
  private let query: Query?
  private let onSuccess: ([T]) -> Success
  private let onFailure: (LoadingError) -> Failure

  public init(
    skeleton: [T],
    query: Query?,
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
        .animation(.default, value: loadingState)
        .task {
          let db = Firestore.firestore()
          do {
            for try await data in db.listen(query, type: T.self) {
              logger.debug(message: data)
              self.loadingState = .loaded(data: data)
            }
          } catch let loadingError as LoadingError {
            logger.error(message: loadingError)
            self.loadingState = .failed(error: loadingError)
          } catch {
            logger.error(message: error)
            let loadingError = LoadingError(errorDescription: error.localizedDescription)
            self.loadingState = .failed(error: loadingError)
          }
        }
      }
    }
  }
}
