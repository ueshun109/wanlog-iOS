import Foundation

public extension Date {
  func toString(_ dateFormatter: DateFormatter) -> String {
    dateFormatter.string(from: self)
  }
}
