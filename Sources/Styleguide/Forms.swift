import SwiftUI

// MARK: - InputForm

public struct InputForm: View {
  @Binding var text: String
  let maxLength: Int?
  let title: String

  public init(
    title: String,
    text: Binding<String>,
    maxLength: Int? = nil
  ) {
    self.title = title
    self._text = text
    self.maxLength = maxLength
  }

  public var body: some View {
    TextField(title, text: $text)
      .padding(Padding.small)
      .background(Color.Background.secondary)
      .clipShape(
        RoundedRectangle(cornerRadius: 8)
      )
      .onChange(of: text) { new in
        guard let maxLength else { return }
        if new.count > maxLength {
          text = String(text.prefix(maxLength))
        }
      }
  }
}

// MARK: - DateForm

public struct DateForm: View {
  @Binding private var date: Date
  @Binding private var selectable: Bool
  @State private var isEdit: Bool = false
  private let showToggle: Bool

  ///
  /// - Parameters:
  ///   - date: The date value being displayed and selected.
  ///   - selectable: A binding to a property that determines whether the toggle is on or off.
  ///   - showToggle: A property whether the toggle display
  public init(
    date: Binding<Date>,
    selectable: Binding<Bool> = .constant(false),
    showToggle: Bool = false
  ) {
    self._date = date
    self._selectable = selectable
    self.showToggle = showToggle
  }

  public var body: some View {
    VStack {
      selection
      if isEdit { datePicker }
    }
    .onChange(of: selectable) { new in
      withAnimation {
        isEdit = new
      }
    }
    .padding(Padding.small)
    .background(Color.Background.secondary)
    .clipShape(
      RoundedRectangle(cornerRadius: 8)
    )
    .environment(\.locale, Locale(identifier: "ja_JP"))
  }

  @ViewBuilder
  /// 📌 Selection date
  var selection: some View {
    if showToggle {
      Toggle(isOn: $selectable) {
        Button {
          withAnimation {
            if selectable {
              isEdit.toggle()
            }
          }
        } label: {
          if selectable {
            Text(date, format: Date.FormatStyle(date: .complete, time: .omitted))
          } else {
            Text("指定なし")
          }
        }
      }
      .foregroundColor(Color.Label.primary)
    } else {
      HStack {
        Button {
          withAnimation {
            isEdit.toggle()
          }
        } label: {
          Text(date, format: Date.FormatStyle(date: .complete, time: .omitted))
        }
        Spacer()
      }
      .foregroundColor(Color.Label.primary)
    }
  }

  /// 🗓️ Date picker
  var datePicker: some View {
    DatePicker(
      selection: $date,
      displayedComponents: [.date]
    ) {
    }
    .datePickerStyle(.graphical)
  }
}

// MARK: - PickerForm

public struct PickerForm<Item, Style>: View where
  Item: Identifiable,
  Item: Hashable,
  Style: PickerStyle
{
  @Binding private var item: Item
  private let items: [Item]
  private let keyPath: KeyPath<Item, String>
  private let style: Style
  private let title: String

  public init(
    item: Binding<Item>,
    items: [Item],
    keyPath: KeyPath<Item, String>,
    title: String,
    style: Style
  ) {
    self._item = item
    self.items = items
    self.keyPath = keyPath
    self.title = title
    self.style = style
  }

  public var body: some View {
    Picker(title, selection: $item) {
      ForEach(items) {
        Text($0[keyPath: keyPath]).tag($0)
      }
    }
    .pickerStyle(style)
    .padding(Padding.small)
    .background(Color.Background.secondary)
    .clipShape(
      RoundedRectangle(cornerRadius: 8)
    )
  }
}

// MARK: - Previews

struct InputForm_Previews: PreviewProvider {
  struct Item: Identifiable, Hashable {
    var id: String { title }
    var title: String
    static let items: [Item] = [.init(title: "A"), .init(title: "B")]
  }

  @State static var selected: Bool = false

  static var previews: some View {
    Group {
      List {
        Section(
          content: { InputForm(title: "Title", text: .constant("Preview")) },
          header: { Text("Input form") }
        )

        Section(
          content: {
            VStack {
              DateForm(date: .constant(.now))
              DateForm(date: .constant(.now), selectable: $selected, showToggle: true)
            }
          },
          header: { Text("Header light") }
        )


        Section {
          PickerForm(
            item: .constant(Item.items.first!),
            items: Item.items,
            keyPath: \.title,
            title: "Picker",
            style: .segmented
          )
        } header: {
          Text("Picker")
        }
      }
      .listStyle(.insetGrouped)

      Form {
        Section(
          content: { InputForm(title: "Title", text: .constant("Preview")) },
          header: { Text("Input form") }
        )

        Section(
          content: {
            VStack {
              DateForm(date: .constant(.now))
              DateForm(date: .constant(.now), selectable: $selected, showToggle: true)
            }
          },
          header: { Text("Date form") }
        )

        Section {
          PickerForm(
            item: .constant(Item.items.first!),
            items: Item.items,
            keyPath: \.title,
            title: "Picker",
            style: .segmented
          )
        } header: {
          Text("Picker")
        }
      }
      .environment(\.colorScheme, .dark)
    }
  }
}
