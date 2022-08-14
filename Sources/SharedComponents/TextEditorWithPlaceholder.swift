import SwiftUI

public struct TextEditorWithPlaceholder: View {

  @FocusState private var focusedField: Field?

  public enum Field: Hashable {
    case textEditor
    case placeholder
  }

  @Binding private var text: String
  private let placeholderText: String

  public init(_ placeholder: String, text: Binding<String>) {
    self._text = text
    self.placeholderText = placeholder
  }

  public var body: some View {
    ZStack {
      if text.isEmpty {
        ZStack {
          Rectangle()
            .fill(Color(uiColor: .systemBackground))
            .onTapGesture {
              focusedField = .placeholder
            }

          VStack {
            HStack {
              TextField(placeholderText, text: $text)
                .focused($focusedField, equals: .placeholder)
                .onAppear {
                  focusedField = .placeholder
                }

              Spacer()
            }
            Spacer()
          }
        }
      } else {
        TextEditor(text: $text)
          .focused($focusedField, equals: .textEditor)
          .onAppear {
            focusedField = .textEditor
          }
      }
    }
  }
}
