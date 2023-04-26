import SharedModels
import Styleguide
import SwiftUI

public struct MultiSelectionList<E: RawRepresentable & Hashable & CaseIterable & Identifiable>: View
where E.RawValue == String, E.AllCases == Array<E>
{
  @Binding var selections: Set<E>
  let headerTitle: String

  public init(selections: Binding<Set<E>>, headerTitle: String) {
    self._selections = selections
    self.headerTitle = headerTitle
  }

  public var body: some View {
    List(selection: $selections) {
      Section {
        ForEach(E.allCases) { item in
          Text(item.rawValue).tag(item)
        }
      } header: {
        Text(headerTitle)
          .padding(.vertical, Padding.xSmall)
      }
    }
    .environment(\.editMode, .constant(.active))
  }
}


struct MultiSelectionListPreview: PreviewProvider {
  @State private static var selection: Set<ReminderDate> = []
  static var previews: some View {
    MultiSelectionList(selections: $selection, headerTitle: "test")
  }
}
