import SwiftUI

public struct CheckBox: View {
  private let checked: Bool
  private let onChange: (Bool) -> ()

  public init(
    checked: Bool,
    onChange: @escaping (Bool) -> ()
  ) {
    self.checked = checked
    self.onChange = onChange
  }

  public var body: some View {
    Button {
      onChange(!checked)
    } label: {
      if checked {
        Image.checkmarkCircleFill
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundColor(.green)

      } else {
        Image.checkmark
          .resizable()
          .frame(width: 8, height: 8)
          .foregroundColor(.gray)
          .opacity(0.5)
          .padding(4)
          .overlay {
            Circle()
              .stroke(lineWidth: 1)
              .foregroundColor(.gray)
          }
      }
    }
  }
}

struct CheckBox_Previews: PreviewProvider {
  static var previews: some View {
    CheckBox(checked: false) { _ in

    }
  }
}
