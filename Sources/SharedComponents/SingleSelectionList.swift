import SharedModels
import Styleguide
import SwiftUI

public struct SingleSelectionList<E: RawRepresentable & Hashable & CaseIterable & Identifiable>: View
where E.RawValue == String, E.AllCases == Array<E>
{
  @Binding var selection: E?
  let headerTitle: String

  public init(selection: Binding<E?>, headerTitle: String) {
    self._selection = selection
    self.headerTitle = headerTitle
  }

  public var body: some View {
    List(selection: $selection) {
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


struct SingleSelectionListPreview: PreviewProvider {
  @State private static var selection: ReminderDate? = nil
  static var previews: some View {
    SingleSelectionList(selection: $selection, headerTitle: "test")
  }
}
