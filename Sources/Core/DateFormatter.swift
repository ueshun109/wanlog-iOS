import Foundation

public extension DateFormatter {
  enum Template: String {
    case dateSlash = "yMd"  // 2021/12/1
  }

  func setTemplate(_ template: Template) {
    dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: Locale(identifier: "ja_JP"))
  }
}

public extension DateFormatter {
  /// e.g. 2022/12/1
  static let yearAndMonthAndDayWithSlash: DateFormatter = {
    let formatter = DateFormatter()
    formatter.setTemplate(.dateSlash)
    return formatter
  }()
}
