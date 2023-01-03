public struct Owner: Codable {
  public var deviceToken: String

  public init(deviceToken: String) {
    self.deviceToken = deviceToken
  }
}
