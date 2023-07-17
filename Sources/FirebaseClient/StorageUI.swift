import FirebaseStorage
import SwiftUI

public struct FIRStorageImage<Content>: View where Content: View {
  @State private var phase: AsyncImagePhase
  private let content: (AsyncImagePhase) -> Content
  private let reference: String?
  private let storage: Storage = .storage()

  public var body: some View {
    content(phase)
      .onChange(of: reference) { new in
        guard let new, !new.isEmpty else { return }
        Task { await load(with: new) }
      }
      .task {
        if case .empty = phase {
          await load(with: reference)
        }
      }
  }

  public init(reference: String?) where Content == Image {
    self.init(reference: reference) { phase in
      phase.image ?? Image(uiImage: .init())
    }
  }

  public init<I, P>(
    reference: String?,
    content: @escaping (Image) -> I,
    placeholder: @escaping () -> P
  ) where Content == _ConditionalContent<I, P>, I: View, P: View {
    self.init(reference: reference) { phage in
      if let image = phage.image {
        content(image)
      } else {
        placeholder()
      }
    }
  }

  public init(
    reference: String?,
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    self.reference = reference
    self.content = content
    self._phase = State(wrappedValue: .empty)
  }

  private func load(with reference: String?) async {
    do {
      if let reference {
        let image = try await remoteImage(form: reference)
        withAnimation {
          phase = .success(image)
        }
      } else {
        withAnimation {
          phase = .empty
        }
      }
    } catch {
      withAnimation {
        phase = .failure(error)
      }
    }
  }

  private func remoteImage(form reference: String) async throws -> Image {
    do {
      let data = try await storage.reference(withPath: reference).get()
      return try image(from: data)
    } catch {
      throw AsyncImage<Content>.LoadingError()
    }
  }

  private func image(from data: Data) throws -> Image {
    if let uiImage = UIImage(data: data) {
      return Image(uiImage: uiImage)
    } else {
      throw AsyncImage<Content>.LoadingError()
    }
  }
}

private extension AsyncImage {
  struct LoadingError: Error {
  }
}
