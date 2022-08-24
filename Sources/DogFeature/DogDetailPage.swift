import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct DogDetailPage: View {
  private struct UiState {
    var biologicalSex: BiologicalSex = .male
    var birthDate: Date = .init()
    var loading: Loading = .idle
    var name: String = ""
    var showAlert: Bool = false
    var showCamera: Bool = false
  }
  @State private var image: UIImage?
  @State private var uiState = UiState()

  private let dog: Dog
  private let storage: Storage = .storage()

  public init(dog: Dog) {
    self.dog = dog
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: Padding.large) {
        VStack(spacing: Padding.xSmall) {
          HeaderSection(image: image)
            .onTapGesture {
              uiState.showCamera.toggle()
            }

          NameSection(name: $uiState.name)

          BirthDateSection(birthDate: $uiState.birthDate)

          BiologicalSexSection(biologicalSex: $uiState.biologicalSex)
        }

        VStack(spacing: Padding.small) {
          ScheduleSection()

          Divider()
            .padding(.trailing, -Padding.xSmall)

          HistorySection()
        }
        .foregroundColor(Color.Label.primary)
        .padding(Padding.small)
        .background(Color.Background.secondary)
        .clipShape(
          RoundedRectangle(cornerRadius: 8)
        )
      }
      .padding(.horizontal, Padding.medium)
    }
    .background(Color.Background.primary)
    .sheet(isPresented: $uiState.showCamera) {
      CameraView(image: $image)
    }
    .onAppear {
      uiState.biologicalSex = dog.biologicalSex
      uiState.birthDate = dog.birthDate.dateValue()
      uiState.name = dog.name
    }
    .task {
      if let refString = dog.iconRef {
        do {
          let data = try await storage.reference(withPath: refString).get()
          image = UIImage(data: data)
        } catch {
          // TODO: エラーハンドリング
        }
      }
    }
  }

  private struct ScheduleSection: View {
    var body: some View {
      NavigationLink {

      } label: {
        HStack {
          Text("予定一覧")

          Spacer()

          Image.chevronForward
        }
      }
    }
  }

  private struct HistorySection: View {
    var body: some View {
      NavigationLink {

      } label: {
        HStack {
          Text("証明書一覧")

          Spacer()

          Image.chevronForward
        }
      }
    }
  }
}
