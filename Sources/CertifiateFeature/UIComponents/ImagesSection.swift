import Core
import SharedComponents
import Styleguide
import SwiftUI

struct ImagesSection: View {
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
        // The number of items has changed from 0 to 1.
        let firstItemAppended = !new.isEmpty && new.count == 1
        if firstItemAppended { selectImageIndex = 0 }
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
                  remove(image: image)
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
}

private extension ImagesSection {
  func remove(image: UIImage) {
    guard let removedIndex = images.firstIndex(of: image) else { return }
    let lastIndex = images.count - 1
    images.remove(at: removedIndex)

    // Set the selected index to nil because when selected images count is zero, selecting index is not existing.
    guard !images.isEmpty else { selectImageIndex = nil; return }

    // e.g When max index and selected index and removed index is 2,
    // the index that does not exist will remain selected unless the index is -1.
    if let index = selectImageIndex, index == removedIndex, removedIndex == lastIndex {
      selectImageIndex = index - 1
    }
  }
}

