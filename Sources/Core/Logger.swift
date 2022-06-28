public class ConsoleLog {
  /// Used to display messages that are useful only during development.
  public static func debug<T>(
    file: String = #file,
    _ function: String = #function,
    line: Int = #line,
    message: T
  ) {
    let string = "💚 DEBUG \(fileNameWithoutSuffix(file)).\(function):\(line) - \(message) "
    print(string)
  }

  /// Used to display normal messages.
  public static func info<T>(
    file: String = #file,
    _ function: String = #function,
    line: Int = #line,
    message: T
  ) {
    let string = "💙 INFO \(fileNameWithoutSuffix(file)).\(function):\(line) - \(message) "
    print(string)
  }

  /// Used when an expected error occurs.
  public static func warning<T>(
    file: String = #file,
    _ function: String = #function,
    line: Int = #line,
    message: T
  ) {
    let string = "💛 WARNING \(fileNameWithoutSuffix(file)).\(function):\(line) - \(message) "
    print(string)
  }

  /// Used when an unexpected error occurs.
  public static func error<T>(
    file: String = #file,
    _ function: String = #function,
    line: Int = #line,
    message: T
  ) {
    let string = "❤️ ERROR \(fileNameWithoutSuffix(file)).\(function):\(line) - \(message) "
    print(string)
  }

  /// Return file name from path.
  private static func fileNameOfFile(_ file: String) -> String {
    let fileParts = file.components(separatedBy: "/")
    if let lastPart = fileParts.last {
      return lastPart
    }
    return ""
  }

  /// Return file name without extension.
  private static func fileNameWithoutSuffix(_ file: String) -> String {
    let fileName = fileNameOfFile(file)

    if !fileName.isEmpty {
      let fileNameParts = fileName.components(separatedBy: ".")
      if let firstPart = fileNameParts.first {
        return firstPart
      }
    }
    return ""
  }
}

public let logger = ConsoleLog.self
