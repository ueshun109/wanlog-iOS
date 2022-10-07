import Core
import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CreateCertificatePage: View {
  private struct UiState {
    var date: Date = .now
    var dogs: [Dog] = []
    var images: LimitedArray<UIImage?> = .init(3)
    var memo: String = ""
    var ownerId: String = ""
    var pick: Pick = .new
    var selectedDog: Dog?
    var selectImageIndex: Int?
    var showCamera = false
    var showConfirmationDialog = false
    var showDogModal = false
    var showPhotoLibrary = false
    var title: String = ""
  }

  private enum Pick {
    case new
    case change(index: Int)
  }

  @Environment(\.dismiss) private var dismiss
  @FocusState private var focused: Bool
  @State private var uiState = UiState()

  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()

  public init() {}

  public var body: some View {
    ScrollView {
      VStack(spacing: Padding.medium) {
        ImagesSection(
          images: $uiState.images,
          pick: $uiState.pick,
          showConfirmationDialog: $uiState.showConfirmationDialog,
          selectImageIndex: $uiState.selectImageIndex
        )

        ContentSection(
          title: $uiState.title,
          memo: $uiState.memo,
          focused: _focused
        )
        .padding(Padding.xSmall)

        DogSection(
          showDogsModal: $uiState.showDogModal,
          focused: _focused,
          dog: uiState.selectedDog
        )
        .padding(Padding.xSmall)

        DateSection(
          date: $uiState.date,
          focused: _focused
        )
        .padding(Padding.xSmall)
      }
    }
    .background(Color.Background.primary)
    .navigationTitle("証明書追加")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolBar {

      } onSave: {

      }
    }
    .confirmationDialog(
      "",
      isPresented: $uiState.showConfirmationDialog,
      titleVisibility: .hidden
    ) {
      ConfirmationDialog(
        showCamera: $uiState.showCamera,
        showPhotoLibrary: $uiState.showPhotoLibrary
      )
    }
    .halfModal(isShow: $uiState.showDogModal) {
      // I want to use `init(_:selection:rowContent:)`, but I have implement it myself.
      // Because the behavior is unstable.
      List(uiState.dogs) { dog in
        DogListItem(selection: $uiState.selectedDog, dog: dog)
      }
    } onEnd: { }
    .sheet(isPresented: $uiState.showCamera) {
      switch uiState.pick {
      case .new:
        CameraView { image in
          uiState.images.append(image)
        }
      case .change(let index):
        CameraView(image: $uiState.images[index])
      }
    }
    .sheet(isPresented: $uiState.showPhotoLibrary) {
      switch uiState.pick {
      case .new:
        PhotoLibraryView { image in
          uiState.images.append(image)
        }
      case .change(let index):
        PhotoLibraryView(image: $uiState.images[index])
      }
    }
    .task {
      guard let uid = await authenticator.user()?.uid else { return }
      uiState.ownerId = uid
      do {
        let query: Query.Dog = .all(uid: uid)
        if let dogs = try await db.get(query: query.collection(), type: Dog.self) {
          uiState.dogs = dogs
        }
      } catch {
      }
    }
  }

  // MARK: - Sections

  private struct ConfirmationDialog: View {
    @Binding var showCamera: Bool
    @Binding var showPhotoLibrary: Bool

    var body: some View {
      Button {
        showCamera = true
      } label: {
        Text("写真を撮る")
      }

      Button {
        showPhotoLibrary = true
      } label: {
        Text("写真を選択")
      }
    }
  }

  private struct ImagesSection: View {
    @Binding var images: LimitedArray<UIImage?>
    @Binding var pick: Pick
    @Binding var showConfirmationDialog: Bool
    @Binding var selectImageIndex: Int?

    var body: some View {
      VStack(spacing: Padding.small) {
        Group {
          if let selectImageIndex, let image = images[selectImageIndex] {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .frame(maxWidth: .infinity)
          } else {
            ZStack {
              Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(maxWidth: .infinity)
                .aspectRatio(1.6, contentMode: .fit)

              Image.cameraFill
                .resizable()
                .scaledToFit()
                .frame(width: 60)
            }
            .onTapGesture {
              pick = .new
              showConfirmationDialog = true
            }
          }
        }
        .onChange(of: images) { new in
          if !new.isEmpty && new.count == 1 {
            selectImageIndex = 0
          }
        }

        ScrollView(.horizontal) {
          HStack {
            ForEach(images, id: \.self) { image in
              if let image {
                ImageListItem(
                  isSelected: images.firstIndex(of: image) == selectImageIndex,
                  image: image
                ) {
                  selectImageIndex = images.firstIndex(of: image)
                }
                .contextMenu {
                  PhotoMenu {
                    guard let index = images.firstIndex(of: image) else { return }
                    pick = .change(index: index)
                    showConfirmationDialog = true
                  } onDelete: {
                    guard let removedIndex = images.firstIndex(of: image) else { return }
                    images.remove(at: removedIndex)
                    if removedIndex == 0 {
                      selectImageIndex = nil
                    } else if let index = selectImageIndex, removedIndex == index {
                      selectImageIndex = index - 1
                    }
                  }
                }
              }
            }

            Button {
              pick = .new
              showConfirmationDialog = true
            } label: {
              Image.plusCircle
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            }
          }
          .padding(.horizontal, Padding.medium)
        }
      }
    }
  }

  private struct ImageListItem: View {
    let isSelected: Bool
    var image: UIImage
    let onTap: () -> Void

    var body: some View {
      Button(action: onTap) {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: 60, height: 60)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.blue, lineWidth: isSelected ? 5 : 0)
          )
          .cornerRadius(8)
      }
    }
  }

  private struct PhotoMenu: View {
    let onReplace: () -> Void
    let onDelete: () -> Void

    @ViewBuilder
    var body: some View {
      Button(action: onReplace) {
        HStack {
          Text("変更")
          Spacer()
          Image.photo
        }
      }

      Button(
        role: .destructive,
        action: onDelete
      ) {
        HStack {
          Text("削除")
          Spacer()
          Image.trash
        }
      }
    }
  }

  private struct ToolBar: ToolbarContent {
    let onCancel: () -> Void
    let onSave: () -> Void

    @ViewBuilder
    var body: some ToolbarContent {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: onCancel) {
          Text("キャンセル")
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: onSave) {
          Text("保存")
        }
//        .disabled(uiState.name.isEmpty || image == nil)
      }
    }
  }
}
